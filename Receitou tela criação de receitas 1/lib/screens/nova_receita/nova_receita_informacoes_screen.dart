import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/rascunho_repository.dart';
import '../../models/receita_rascunho.dart';
import '../../theme/app_theme.dart';
import 'nova_receita_ingredientes_screen.dart';
import 'widgets/indicador_passos.dart';

typedef SelecionarImagem = Future<XFile?> Function(ImageSource origem);

enum _OpcaoSair { salvar, descartar, cancelar }

/// Nova Receita · Passo 1: Informações Básicas.
/// Spec: specs/nova_receita_passo1_informacoes.md
class NovaReceitaInformacoesScreen extends StatefulWidget {
  static const tamanhoMaxFoto = 10 * 1024 * 1024;
  static const extensoesFoto = ['.jpg', '.jpeg', '.png'];

  final RascunhoRepository repository;
  final SelecionarImagem? selecionarImagem;

  NovaReceitaInformacoesScreen({
    super.key,
    RascunhoRepository? repository,
    this.selecionarImagem,
  }) : repository = repository ?? RascunhoRepository();

  @override
  State<NovaReceitaInformacoesScreen> createState() =>
      _NovaReceitaInformacoesScreenState();
}

class _NovaReceitaInformacoesScreenState
    extends State<NovaReceitaInformacoesScreen> {
  final _rascunho = ReceitaRascunho();
  final _tituloController = TextEditingController();
  final _historiaController = TextEditingController();
  final _tituloKey = GlobalKey();

  String? _erroTitulo;
  bool _tentouContinuar = false;

  // Estado da última vez que salvou, para detectar alterações pendentes.
  late String _estadoSalvo;

  @override
  void initState() {
    super.initState();
    _estadoSalvo = _assinatura();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _historiaController.dispose();
    super.dispose();
  }

  String _assinatura() => [
        _rascunho.fotoCapa,
        _tituloController.text,
        _rascunho.categoria.name,
        _historiaController.text,
      ].join('\u0000');

  bool get _temAlteracoes => _assinatura() != _estadoSalvo;

  void _sincronizarCampos() {
    _rascunho
      ..titulo = _tituloController.text.trim()
      ..historia = _historiaController.text;
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _salvarRascunho() async {
    _sincronizarCampos();
    await widget.repository.salvar(_rascunho);
    _estadoSalvo = _assinatura();
    if (mounted) _avisar('Rascunho salvo');
  }

  Future<void> _fechar() async {
    final navigator = Navigator.of(context);
    if (!_temAlteracoes) {
      navigator.pop();
      return;
    }
    final opcao = await showDialog<_OpcaoSair>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar receita?'),
        content: const Text('Você tem alterações que ainda não foram salvas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _OpcaoSair.cancelar),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _OpcaoSair.descartar),
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _OpcaoSair.salvar),
            child: const Text('Salvar rascunho'),
          ),
        ],
      ),
    );
    switch (opcao) {
      case _OpcaoSair.salvar:
        await _salvarRascunho();
        navigator.pop();
      case _OpcaoSair.descartar:
        navigator.pop();
      case _OpcaoSair.cancelar || null:
        break;
    }
  }

  Future<void> _escolherFoto() async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origem == null) return;

    final selecionar = widget.selecionarImagem ??
        (origem) => ImagePicker().pickImage(source: origem);
    final arquivo = await selecionar(origem);
    if (arquivo == null || !mounted) return;

    final nome = arquivo.name.toLowerCase();
    final formatoValido = NovaReceitaInformacoesScreen.extensoesFoto
        .any((extensao) => nome.endsWith(extensao));
    if (!formatoValido ||
        await arquivo.length() > NovaReceitaInformacoesScreen.tamanhoMaxFoto) {
      _avisar('Use uma imagem JPG ou PNG de até 10 MB.');
      return;
    }
    setState(() => _rascunho.fotoCapa = arquivo.path);
  }

  void _continuar() {
    final erro = ReceitaRascunho.validarTitulo(_tituloController.text);
    setState(() {
      _tentouContinuar = true;
      _erroTitulo = erro;
    });
    if (erro != null) {
      Scrollable.ensureVisible(
        _tituloKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        alignment: 0.2,
      );
      return;
    }
    _sincronizarCampos();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovaReceitaIngredientesScreen(rascunho: _rascunho),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _fechar();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: _fechar,
          ),
          title: const Text('Nova Receita'),
        ),
        body: Column(
          children: [
            const IndicadorPassos(passoAtual: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações Básicas',
                      style: TextStyle(
                        fontFamily: AppTheme.fonteSerifada,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Comece dando um rosto e um nome para a sua criação '
                      'culinária.',
                      style: TextStyle(fontSize: 15, color: AppColors.texto),
                    ),
                    const SizedBox(height: 24),
                    _FotoCapa(
                      caminho: _rascunho.fotoCapa,
                      onTap: _escolherFoto,
                      onRemover: () =>
                          setState(() => _rascunho.fotoCapa = null),
                    ),
                    const SizedBox(height: 24),
                    const _Rotulo('Título da Receita'),
                    TextField(
                      key: _tituloKey,
                      controller: _tituloController,
                      maxLength: ReceitaRascunho.tituloMax,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onChanged: (valor) => setState(() {
                        if (_tentouContinuar) {
                          _erroTitulo = ReceitaRascunho.validarTitulo(valor);
                        }
                      }),
                      decoration: InputDecoration(
                        hintText: 'Ex: Risoto de Cogumelos Selvagens',
                        counterText: '',
                        errorText: _erroTitulo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _Rotulo('Categoria Principal'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final categoria in Categoria.values)
                          _ChipCategoria(
                            categoria: categoria,
                            selecionado: categoria == _rascunho.categoria,
                            onTap: () => setState(
                                () => _rascunho.categoria = categoria),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _Rotulo('História ou Descrição'),
                    TextField(
                      controller: _historiaController,
                      maxLength: ReceitaRascunho.historiaMax,
                      minLines: 4,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'O que torna esta receita especial? Conte a '
                            'inspiração por trás dela...',
                        hintMaxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _Rodape(onSalvar: _salvarRascunho, onContinuar: _continuar),
          ],
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;

  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
      ),
    );
  }
}

class _FotoCapa extends StatelessWidget {
  final String? caminho;
  final VoidCallback onTap;
  final VoidCallback onRemover;

  const _FotoCapa({
    required this.caminho,
    required this.onTap,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(12);
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Material(
            color: AppColors.superficie,
            borderRadius: raio,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: caminho != null
                  // Na web, o caminho do XFile é uma URL blob:.
                  ? kIsWeb
                      ? Image.network(caminho!, fit: BoxFit.cover)
                      : Image.file(File(caminho!), fit: BoxFit.cover)
                  : CustomPaint(
                      painter: _BordaTracejada(raio: 12),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 32,
                            color: AppColors.terracota,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Adicionar Foto de Capa',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.texto,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Formatos recomendados: JPG, PNG (Paisagem)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (caminho != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                tooltip: 'Remover foto',
                icon: const Icon(Icons.close, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: onRemover,
              ),
            ),
        ],
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  final double raio;

  _BordaTracejada({required this.raio});

  @override
  void paint(Canvas canvas, Size size) {
    const traco = 6.0, espaco = 4.0;
    final paint = Paint()
      ..color = AppColors.borda
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final contorno = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(0.75),
        Radius.circular(raio),
      ));
    for (final metrica in contorno.computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += traco + espaco) {
        canvas.drawPath(metrica.extractPath(d, d + traco), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejada oldDelegate) => oldDelegate.raio != raio;
}

class _ChipCategoria extends StatelessWidget {
  final Categoria categoria;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipCategoria({
    required this.categoria,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(categoria.rotulo),
      selected: selecionado,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.terracota,
      backgroundColor: AppColors.superficie,
      side: BorderSide(
        color: selecionado ? AppColors.terracota : AppColors.borda,
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selecionado ? Colors.white : AppColors.texto,
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final VoidCallback onSalvar;
  final VoidCallback onContinuar;

  const _Rodape({required this.onSalvar, required this.onContinuar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.fundo,
        border: Border(top: BorderSide(color: AppColors.borda)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onSalvar,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.texto,
                  ),
                  child: const Text(
                    'Salvar Rascunho',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onContinuar,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.terracota,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
