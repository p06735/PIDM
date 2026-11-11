import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/receita_rascunho.dart';
import '../../theme/app_theme.dart';
import 'nova_receita_fluxo.dart';
import 'nova_receita_metodo_screen.dart';
import 'widgets/componentes_fluxo.dart';
import 'widgets/indicador_passos.dart';

/// Nova Receita · Passo 2: Ingredientes.
/// Spec: specs/nova_receita_passo2_ingredientes.md
///
/// Ao fechar pelo X, a rota retorna `true` para que o passo anterior também
/// feche. Voltar (rodapé ou voltar do sistema) retorna `null` e mantém o
/// fluxo aberto.
class NovaReceitaIngredientesScreen extends StatefulWidget {
  final NovaReceitaFluxo fluxo;

  const NovaReceitaIngredientesScreen({super.key, required this.fluxo});

  @override
  State<NovaReceitaIngredientesScreen> createState() =>
      _NovaReceitaIngredientesScreenState();
}

/// Uma linha editável da lista (quantidade + descrição).
class _Linha {
  final key = GlobalKey();
  final TextEditingController quantidade;
  final TextEditingController descricao;
  final focoQuantidade = FocusNode();
  final focoDescricao = FocusNode();
  bool erro = false;

  _Linha([Ingrediente ingrediente = const Ingrediente()])
    : quantidade = TextEditingController(text: ingrediente.quantidade),
      descricao = TextEditingController(text: ingrediente.descricao);

  bool get _temQuantidade => quantidade.text.trim().isNotEmpty;
  bool get _temDescricao => descricao.text.trim().isNotEmpty;

  bool get vazia => !_temQuantidade && !_temDescricao;
  bool get valida => _temDescricao;
  bool get incompleta => _temQuantidade && !_temDescricao;
  bool get temFoco => focoQuantidade.hasFocus || focoDescricao.hasFocus;

  Ingrediente get ingrediente => Ingrediente(
    quantidade: quantidade.text.trim(),
    descricao: descricao.text.trim(),
  );

  void dispose() {
    quantidade.dispose();
    descricao.dispose();
    focoQuantidade.dispose();
    focoDescricao.dispose();
  }
}

class _NovaReceitaIngredientesScreenState
    extends State<NovaReceitaIngredientesScreen> {
  static const _max = ReceitaRascunho.ingredientesMax;

  final _linhas = <_Linha>[];

  // Linhas fora da lista (removidas ou descartadas); descartadas no dispose
  // porque o "Desfazer" pode reinseri-las.
  final _foraDaLista = <_Linha>[];

  bool _erroLista = false;

  ReceitaRascunho get _rascunho => widget.fluxo.rascunho;

  @override
  void initState() {
    super.initState();
    _linhas.addAll(_rascunho.ingredientes.map(_Linha.new));
    _normalizar();
  }

  @override
  void dispose() {
    for (final linha in [..._linhas, ..._foraDaLista]) {
      linha.dispose();
    }
    super.dispose();
  }

  /// Mantém exatamente uma linha vazia no fim da lista (exceto no limite).
  void _normalizar() {
    while (_linhas.length >= 2 &&
        _linhas.last.vazia &&
        _linhas[_linhas.length - 2].vazia &&
        !_linhas.last.temFoco) {
      _foraDaLista.add(_linhas.removeLast());
    }
    if (_linhas.length > _max && _linhas.last.vazia) {
      _foraDaLista.add(_linhas.removeLast());
    }
    if ((_linhas.isEmpty || !_linhas.last.vazia) && _linhas.length < _max) {
      _linhas.add(_Linha());
    }
  }

  /// Copia a lista da tela para o rascunho, ignorando linhas vazias.
  void _sincronizar() {
    _rascunho.ingredientes = [
      for (final linha in _linhas)
        if (!linha.vazia) linha.ingrediente,
    ];
  }

  void _aoAlterar(_Linha linha, {bool descricao = false}) {
    setState(() {
      if (descricao) linha.erro = false;
      _erroLista = false;
      _normalizar();
      _sincronizar();
    });
  }

  void _rolarAte(_Linha linha) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = linha.key.currentContext;
      if (contexto == null) return;
      Scrollable.ensureVisible(
        contexto,
        duration: const Duration(milliseconds: 300),
        alignment: 0.2,
      );
    });
  }

  void _descricaoConcluida(_Linha linha) {
    final proxima = _linhas.indexOf(linha) + 1;
    if (proxima < _linhas.length) {
      _linhas[proxima].focoQuantidade.requestFocus();
      _rolarAte(_linhas[proxima]);
    } else {
      linha.focoDescricao.unfocus();
    }
  }

  void _remover(_Linha linha) {
    final indice = _linhas.indexOf(linha);
    setState(() {
      _linhas.removeAt(indice);
      _foraDaLista.add(linha);
      _normalizar();
      _sincronizar();
    });
    avisar(
      context,
      'Ingrediente removido',
      acao: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          if (!mounted) return;
          // Enquanto o aviso estava aberto, o usuário pode ter preenchido a
          // lista até o limite; restaurar o item ultrapassaria os 50.
          if (_linhas.where((l) => !l.vazia).length >= _max) {
            avisar(context, 'Você atingiu o limite de $_max ingredientes.');
            return;
          }
          if (!_foraDaLista.remove(linha)) return;
          setState(() {
            _linhas.insert(min(indice, _linhas.length), linha);
            _normalizar();
            _sincronizar();
          });
        },
      ),
    );
  }

  void _adicionar() {
    final ultima = _linhas.last;
    if (!ultima.vazia) {
      avisar(context, 'Você atingiu o limite de $_max ingredientes.');
      return;
    }
    ultima.focoQuantidade.requestFocus();
    _rolarAte(ultima);
  }

  Future<void> _continuar() async {
    final incompletas = _linhas.where((l) => l.incompleta).toList();
    if (incompletas.isNotEmpty) {
      setState(() {
        for (final linha in _linhas) {
          linha.erro = linha.incompleta;
        }
      });
      _rolarAte(incompletas.first);
      return;
    }
    if (!_linhas.any((l) => l.valida)) {
      setState(() => _erroLista = true);
      _linhas.first.focoDescricao.requestFocus();
      return;
    }

    setState(() {
      final vazias = _linhas.where((l) => l.vazia).toList();
      _linhas.removeWhere(vazias.contains);
      _foraDaLista.addAll(vazias);
      _normalizar();
      _sincronizar();
    });

    final navigator = Navigator.of(context);
    final fecharFluxo = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => NovaReceitaMetodoScreen(fluxo: widget.fluxo),
      ),
    );
    if (fecharFluxo == true) navigator.pop(true);
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
          onPressed: _fechar,
        ),
        title: const Text('Nova Receita'),
      ),
      body: Column(
        children: [
          const IndicadorPassos(passoAtual: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CabecalhoPasso(
                    titulo: 'Lista de Ingredientes',
                    subtitulo:
                        'Quais ingredientes são necessários para preparar '
                        'essa delícia? Liste-os com clareza.',
                  ),
                  const SizedBox(height: 24),
                  for (final linha in _linhas)
                    _LinhaIngrediente(
                      key: linha.key,
                      linha: linha,
                      mostrarRemover: !(linha == _linhas.last && linha.vazia),
                      onQuantidadeAlterada: () => _aoAlterar(linha),
                      onDescricaoAlterada: () =>
                          _aoAlterar(linha, descricao: true),
                      onDescricaoConcluida: () => _descricaoConcluida(linha),
                      onRemover: () => _remover(linha),
                    ),
                  if (_erroLista)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Adicione pelo menos um ingrediente.',
                        style: TextStyle(fontSize: 13, color: AppColors.erro),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _adicionar,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Adicionar Ingrediente',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.terracota,
                        side: const BorderSide(color: AppColors.terracota),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
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
        iconeSecundario: Icons.arrow_back,
        onSecundario: _voltar,
        onContinuar: _continuar,
        teclado: MediaQuery.viewInsetsOf(context).bottom,
      ),
    );
  }
}

class _LinhaIngrediente extends StatelessWidget {
  final _Linha linha;
  final bool mostrarRemover;
  final VoidCallback onQuantidadeAlterada;
  final VoidCallback onDescricaoAlterada;
  final VoidCallback onDescricaoConcluida;
  final VoidCallback onRemover;

  const _LinhaIngrediente({
    super.key,
    required this.linha,
    required this.mostrarRemover,
    required this.onQuantidadeAlterada,
    required this.onDescricaoAlterada,
    required this.onDescricaoConcluida,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: linha.quantidade,
              focusNode: linha.focoQuantidade,
              maxLength: Ingrediente.quantidadeMax,
              textInputAction: TextInputAction.next,
              onChanged: (_) => onQuantidadeAlterada(),
              onEditingComplete: linha.focoDescricao.requestFocus,
              decoration: const InputDecoration(
                hintText: 'Qtd',
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: TextField(
              controller: linha.descricao,
              focusNode: linha.focoDescricao,
              maxLength: Ingrediente.descricaoMax,
              // Quebra visualmente em várias linhas, mas Enter vai para o
              // próximo campo em vez de inserir uma quebra de linha.
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: null,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              // Texto colado com quebras de linha vira uma linha só, com
              // espaço no lugar da quebra para não grudar as palavras.
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                  RegExp(r'[ \t]*[\r\n]+[ \t]*'),
                  replacementString: ' ',
                ),
              ],
              onChanged: (_) => onDescricaoAlterada(),
              onEditingComplete: onDescricaoConcluida,
              decoration: InputDecoration(
                // O placeholder ocupa 2 linhas; sem esta condição o campo
                // reservaria essa altura mesmo com texto curto.
                hintText: linha.descricao.text.isEmpty
                    ? 'Ex: Gramas de Manteiga...'
                    : null,
                counterText: '',
                errorText: linha.erro ? 'Descreva o ingrediente.' : null,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: mostrarRemover
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remover ingrediente',
                    color: AppColors.texto,
                    onPressed: onRemover,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
