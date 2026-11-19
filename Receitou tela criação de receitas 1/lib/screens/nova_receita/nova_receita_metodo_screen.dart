import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/receita_repository.dart';
import '../../models/receita_rascunho.dart';
import '../../theme/app_theme.dart';
import '../../widgets/imagem_local.dart';
import 'nova_receita_fluxo.dart';
import 'widgets/componentes_fluxo.dart';
import 'widgets/indicador_passos.dart';

typedef SelecionarMidias = Future<List<XFile>> Function();

/// Nova Receita · Passo 3: Modo de Preparo.
/// Spec: specs/nova_receita_passo3_modo_preparo.md
///
/// Fecha com `true` quando o fluxo inteiro deve fechar (X ou Publicar).
/// Voltar retorna `null` e mantém o fluxo aberto.
class NovaReceitaMetodoScreen extends StatefulWidget {
  final NovaReceitaFluxo fluxo;
  final ReceitaRepository receitas;
  final SelecionarMidias? selecionarMidias;

  NovaReceitaMetodoScreen({
    super.key,
    required this.fluxo,
    ReceitaRepository? receitas,
    this.selecionarMidias,
  }) : receitas = receitas ?? ReceitaRepository();

  @override
  State<NovaReceitaMetodoScreen> createState() =>
      _NovaReceitaMetodoScreenState();
}

/// Um cartão editável de passo.
class _Cartao {
  final key = GlobalKey();
  final TextEditingController texto;
  final foco = FocusNode();
  final List<Midia> midias;
  bool erro = false;

  _Cartao([PassoPreparo passo = const PassoPreparo()])
    : texto = TextEditingController(text: passo.descricao),
      midias = [...passo.midias];

  bool get _temTexto => texto.text.trim().isNotEmpty;

  bool get vazio => !_temTexto && midias.isEmpty;
  bool get valido => _temTexto;
  bool get incompleto => !_temTexto && midias.isNotEmpty;

  PassoPreparo get passo =>
      PassoPreparo(descricao: texto.text, midias: [...midias]);

  void dispose() {
    texto.dispose();
    foco.dispose();
  }
}

class _NovaReceitaMetodoScreenState extends State<NovaReceitaMetodoScreen> {
  static const _max = ReceitaRascunho.passosMax;

  final _cartoes = <_Cartao>[];
  final _foraDaLista = <_Cartao>[];

  bool _erroNenhumPasso = false;
  bool _publicando = false;

  ReceitaRascunho get _rascunho => widget.fluxo.rascunho;

  @override
  void initState() {
    super.initState();
    _cartoes.addAll(_rascunho.passos.map(_Cartao.new));
    if (_cartoes.isEmpty) _cartoes.add(_Cartao());
  }

  @override
  void dispose() {
    for (final c in [..._cartoes, ..._foraDaLista]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Copia os cartões com conteúdo para o rascunho (vazios não contam como
  /// alteração).
  void _sincronizar() {
    _rascunho.passos = [
      for (final c in _cartoes)
        if (!c.vazio) c.passo,
    ];
  }

  void _rolarAte(_Cartao cartao) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = cartao.key.currentContext;
      if (contexto == null) return;
      Scrollable.ensureVisible(
        contexto,
        duration: const Duration(milliseconds: 300),
        alignment: 0.1,
      );
    });
  }

  void _aoDigitar(_Cartao cartao) {
    setState(() {
      cartao.erro = false;
      _erroNenhumPasso = false;
      _sincronizar();
    });
  }

  void _adicionar() {
    if (_cartoes.length >= _max) {
      avisar(context, 'Você atingiu o limite de $_max passos.');
      return;
    }
    final novo = _Cartao();
    setState(() => _cartoes.add(novo));
    novo.foco.requestFocus();
    _rolarAte(novo);
  }

  void _remover(_Cartao cartao) {
    final indice = _cartoes.indexOf(cartao);
    FocusScope.of(context).unfocus();
    setState(() {
      _cartoes.removeAt(indice);
      _foraDaLista.add(cartao);
      _sincronizar();
    });
    avisar(
      context,
      'Passo removido',
      acao: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          if (!mounted) return;
          if (_cartoes.length >= _max) {
            avisar(context, 'Você atingiu o limite de $_max passos.');
            return;
          }
          if (!_foraDaLista.remove(cartao)) return;
          setState(() {
            _cartoes.insert(min(indice, _cartoes.length), cartao);
            _sincronizar();
          });
        },
      ),
    );
  }

  Future<void> _adicionarMidia(_Cartao cartao) async {
    final selecionar =
        widget.selecionarMidias ?? () => ImagePicker().pickMultipleMedia();
    final arquivos = await selecionar();
    if (!mounted || arquivos.isEmpty) return;

    var formatoInvalido = false;
    var passouLimite = false;
    final novas = <Midia>[];
    for (final arquivo in arquivos) {
      final midia = Midia.deArquivo(caminho: arquivo.path, nome: arquivo.name);
      if (midia == null) {
        formatoInvalido = true;
      } else if (cartao.midias.length + novas.length >=
          PassoPreparo.midiasMax) {
        passouLimite = true;
      } else {
        novas.add(midia);
      }
    }
    setState(() {
      cartao.midias.addAll(novas);
      _sincronizar();
    });
    if (passouLimite) {
      avisar(
        context,
        'Cada passo pode ter até ${PassoPreparo.midiasMax} fotos ou vídeos.',
      );
    } else if (formatoInvalido) {
      avisar(context, 'Use fotos JPG, PNG ou WEBP, ou vídeos MP4 ou MOV.');
    }
  }

  void _removerMidia(_Cartao cartao, Midia midia) {
    setState(() {
      cartao.midias.remove(midia);
      _sincronizar();
    });
  }

  Future<void> _publicar() async {
    // Trava antes de qualquer `await`: um segundo toque rápido não publica
    // a receita de novo.
    if (_publicando) return;

    final incompletos = _cartoes.where((c) => c.incompleto).toList();
    if (incompletos.isNotEmpty) {
      setState(() {
        for (final c in _cartoes) {
          c.erro = c.incompleto;
        }
      });
      _rolarAte(incompletos.first);
      return;
    }
    if (!_cartoes.any((c) => c.valido)) {
      setState(() => _erroNenhumPasso = true);
      _cartoes.first.foco.requestFocus();
      _rolarAte(_cartoes.first);
      return;
    }

    setState(() => _publicando = true);
    FocusScope.of(context).unfocus();
    _rascunho.passos = [
      for (final c in _cartoes)
        if (c.valido)
          PassoPreparo(descricao: c.texto.text.trim(), midias: [...c.midias]),
    ];

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.receitas.publicar(_rascunho);
      final idRascunho = _rascunho.id;
      if (idRascunho != null) {
        await widget.fluxo.repository.excluir(idRascunho);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _publicando = false);
        avisar(context, 'Não foi possível publicar. Tente de novo.');
      }
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Receita publicada!'), persist: false),
      );
    navigator.pop(true);
  }

  void _voltar() => Navigator.of(context).pop();

  Future<void> _fechar() async {
    final navigator = Navigator.of(context);
    if (await confirmarFechamento(context, widget.fluxo)) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Fechar',
          onPressed: _publicando ? null : _fechar,
        ),
        title: const Text('Nova Receita'),
      ),
      body: Column(
        children: [
          const IndicadorPassos(passoAtual: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CabecalhoPasso(
                    titulo: 'Modo de Preparo',
                    subtitulo:
                        'Explique passo a passo como preparar sua obra-prima.',
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < _cartoes.length; i++)
                    _CartaoPasso(
                      key: _cartoes[i].key,
                      cartao: _cartoes[i],
                      numero: i + 1,
                      mostrarRemover: _cartoes.length > 1,
                      erroTexto: _cartoes[i].erro
                          ? 'Descreva este passo.'
                          : (i == 0 && _erroNenhumPasso)
                          ? 'Descreva pelo menos um passo.'
                          : null,
                      onTextoAlterado: () => _aoDigitar(_cartoes[i]),
                      onRemover: () => _remover(_cartoes[i]),
                      onAdicionarMidia: () => _adicionarMidia(_cartoes[i]),
                      onRemoverMidia: (m) => _removerMidia(_cartoes[i], m),
                    ),
                  OutlinedButton.icon(
                    onPressed: _adicionar,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Adicionar passo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.texto,
                      side: const BorderSide(color: AppColors.terracota),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: RodapeFluxo(
        rotuloSecundario: 'Voltar',
        onSecundario: _publicando ? () {} : _voltar,
        onContinuar: _publicar,
        rotuloPrincipal: 'Publicar',
        iconePrincipal: Icons.check_circle,
        carregando: _publicando,
        teclado: MediaQuery.viewInsetsOf(context).bottom,
      ),
    );
  }
}

class _CartaoPasso extends StatelessWidget {
  final _Cartao cartao;
  final int numero;
  final bool mostrarRemover;
  final String? erroTexto;
  final VoidCallback onTextoAlterado;
  final VoidCallback onRemover;
  final VoidCallback onAdicionarMidia;
  final ValueChanged<Midia> onRemoverMidia;

  const _CartaoPasso({
    super.key,
    required this.cartao,
    required this.numero,
    required this.mostrarRemover,
    required this.erroTexto,
    required this.onTextoAlterado,
    required this.onRemover,
    required this.onAdicionarMidia,
    required this.onRemoverMidia,
  });

  @override
  Widget build(BuildContext context) {
    final cheio = cartao.midias.length >= PassoPreparo.midiasMax;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
      decoration: BoxDecoration(
        color: AppColorsExtra.cartao,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColorsExtra.verdeClaro,
                    shape: BoxShape.circle,
                  ),
                  child: FittedBox(
                    child: Text(
                      '$numero',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColorsExtra.verde,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'PASSO',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColorsExtra.verde,
                    ),
                  ),
                ),
                if (mostrarRemover)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Remover passo $numero',
                    color: AppColors.textoSecundario,
                    onPressed: onRemover,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: cartao.texto,
                  focusNode: cartao.foco,
                  maxLength: PassoPreparo.descricaoMax,
                  minLines: 3,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  onChanged: (_) => onTextoAlterado(),
                  // Contador só perto do limite, para não poluir o cartão.
                  buildCounter:
                      (
                        _, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => currentLength >= 900
                      ? Text('$currentLength/$maxLength')
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Descreva as ações necessárias para este passo...',
                    hintMaxLines: 3,
                    errorText: erroTexto,
                  ),
                ),
                const SizedBox(height: 16),
                if (cartao.midias.isEmpty)
                  _BotaoTracejado(
                    altura: 52,
                    onTap: onAdicionarMidia,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 20,
                          color: AppColors.texto,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Adicionar foto ou vídeo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.texto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final m in cartao.midias)
                        _Miniatura(midia: m, onRemover: () => onRemoverMidia(m)),
                      if (!cheio)
                        SizedBox.square(
                          dimension: 70,
                          child: _BotaoTracejado(
                            onTap: onAdicionarMidia,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 20,
                                    color: AppColors.texto,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Mais fotos',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoTracejado extends StatelessWidget {
  final double? altura;
  final VoidCallback onTap;
  final Widget child;

  const _BotaoTracejado({this.altura, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altura,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: CustomPaint(
            painter: const BordaTracejada(
              raio: 8,
              cor: AppColorsExtra.rosaTracejado,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  final Midia midia;
  final VoidCallback onRemover;

  const _Miniatura({required this.midia, required this.onRemover});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: midia.video
                ? const ColoredBox(
                    color: Color(0xFF2B211C),
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : ImagemLocal(midia.caminho),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemover,
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
