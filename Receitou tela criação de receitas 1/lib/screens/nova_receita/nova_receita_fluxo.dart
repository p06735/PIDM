import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/rascunho_repository.dart';
import '../../models/receita_rascunho.dart';

/// Estado compartilhado pelos 3 passos de "Nova Receita": o rascunho e o
/// controle de alterações ainda não salvas.
class NovaReceitaFluxo {
  final ReceitaRascunho rascunho;
  final RascunhoRepository repository;

  // Assinatura do rascunho na última vez em que foi salvo (ou na criação).
  late String _estadoSalvo;

  NovaReceitaFluxo({ReceitaRascunho? rascunho, RascunhoRepository? repository})
    : rascunho = rascunho ?? ReceitaRascunho(),
      repository = repository ?? RascunhoRepository() {
    _estadoSalvo = _assinatura();
  }

  String _assinatura() => jsonEncode(
    rascunho.toJson()
      ..remove('id')
      ..remove('atualizadoEm'),
  );

  bool get temAlteracoes => _assinatura() != _estadoSalvo;

  Future<void> salvar() async {
    await repository.salvar(rascunho);
    _estadoSalvo = _assinatura();
  }
}

void avisar(BuildContext context, String mensagem, {SnackBarAction? acao}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(mensagem), action: acao, persist: false),
    );
}

enum _OpcaoSair { salvar, descartar, cancelar }

/// Fluxo do botão fechar (X), igual em todos os passos.
/// Retorna `true` se o fluxo deve ser fechado.
Future<bool> confirmarFechamento(
  BuildContext context,
  NovaReceitaFluxo fluxo,
) async {
  if (!fluxo.temAlteracoes) return true;
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
      await fluxo.salvar();
      if (context.mounted) avisar(context, 'Rascunho salvo');
      return true;
    case _OpcaoSair.descartar:
      return true;
    case _OpcaoSair.cancelar || null:
      return false;
  }
}
