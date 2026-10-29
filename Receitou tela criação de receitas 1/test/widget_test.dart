import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:receitou/main.dart';
import 'package:receitou/screens/nova_receita/nova_receita_informacoes_screen.dart';
import 'package:receitou/theme/app_theme.dart';

/// Abre a tela a partir da InicioScreen, para que fechar tenha para onde voltar.
Future<void> abrirTela(WidgetTester tester, {SelecionarImagem? imagem}) async {
  tester.view
    ..physicalSize = const Size(412, 915)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                NovaReceitaInformacoesScreen(selecionarImagem: imagem),
          )),
          child: const Text('abrir'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

/// Rola até o elemento antes de tocar, como o usuário faria.
Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Finder get campoTitulo => find.byType(TextField).first;
Finder get campoHistoria => find.byType(TextField).last;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('CA01 estado inicial', (tester) async {
    await abrirTela(tester);
    expect(find.text('Passo 1 de 3'), findsOneWidget);
    expect(find.text('Adicionar Foto de Capa'), findsOneWidget);
    expect(find.text('Ex: Risoto de Cogumelos Selvagens'), findsOneWidget);
    final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Prato Principal'));
    expect(chip.selected, isTrue);
  });

  testWidgets('CA02 fechar sem alterações volta', (tester) async {
    await abrirTela(tester);
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('CA03/CA06 fechar com alterações mostra diálogo e cancela',
      (tester) async {
    await abrirTela(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsNothing);
    expect(find.text('Bolo'), findsOneWidget);
  });

  testWidgets('CA04 descartar fecha a tela', (tester) async {
    await abrirTela(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('CA05 salvar rascunho no diálogo avisa e fecha', (tester) async {
    await abrirTela(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar rascunho'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
    expect(find.text('Rascunho salvo'), findsOneWidget);
  });

  testWidgets('CA07/CA08/CA11 escolher e remover foto', (tester) async {
    await abrirTela(tester,
        imagem: (_) async =>
            XFile.fromData(Uint8List(10), name: 'capa.jpg', path: 'capa.jpg'));
    await tocar(tester, find.text('Adicionar Foto de Capa'));
    await tester.pumpAndSettle();
    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Escolher da galeria'), findsOneWidget);
    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar Foto de Capa'), findsNothing);
    expect(find.byTooltip('Remover foto'), findsOneWidget);
    await tocar(tester, find.byTooltip('Remover foto'));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar Foto de Capa'), findsOneWidget);
  });

  testWidgets('CA09 arquivo inválido mostra aviso', (tester) async {
    await abrirTela(tester,
        imagem: (_) async => XFile.fromData(Uint8List(10), name: 'capa.gif'));
    await tocar(tester, find.text('Adicionar Foto de Capa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tirar foto'));
    await tester.pumpAndSettle();
    expect(find.text('Use uma imagem JPG ou PNG de até 10 MB.'), findsOneWidget);
    expect(find.text('Adicionar Foto de Capa'), findsOneWidget);
  });

  testWidgets('CA13 título limitado a 60 caracteres', (tester) async {
    await abrirTela(tester);
    await tester.enterText(campoTitulo, 'a' * 61);
    await tester.pump();
    expect(tester.widget<TextField>(campoTitulo).controller!.text.length, 60);
  });

  testWidgets('CA14/CA15 seleção única de categoria', (tester) async {
    await abrirTela(tester);
    bool selecionado(String rotulo) => tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, rotulo))
        .selected;
    await tocar(tester, find.text('Sobremesa'));
    await tester.pump();
    expect(selecionado('Sobremesa'), isTrue);
    expect(selecionado('Prato Principal'), isFalse);
    await tocar(tester, find.text('Sobremesa'));
    await tester.pump();
    expect(selecionado('Sobremesa'), isTrue);
  });

  testWidgets('CA17 contador da história', (tester) async {
    await abrirTela(tester);
    await tester.enterText(campoHistoria, 'Receita da vó');
    await tester.pump();
    expect(find.text('13/500'), findsOneWidget);
    await tester.enterText(campoHistoria, 'x' * 501);
    await tester.pump();
    expect(find.text('500/500'), findsOneWidget);
  });

  testWidgets('CA18 salvar rascunho mantém a tela', (tester) async {
    await abrirTela(tester);
    await tester.tap(find.text('Salvar Rascunho'));
    await tester.pumpAndSettle();
    expect(find.text('Rascunho salvo'), findsOneWidget);
    expect(find.text('Informações Básicas'), findsOneWidget);
  });

  testWidgets('CA20 continuar com título inválido mostra erro',
      (tester) async {
    await abrirTela(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Dê um nome à sua receita.'), findsOneWidget);
    await tester.enterText(campoTitulo, 'Ab');
    await tester.pump();
    expect(find.text('O título precisa ter pelo menos 3 caracteres.'),
        findsOneWidget);
  });

  testWidgets('CA19/CA21 continuar vai ao passo 2 e volta com dados',
      (tester) async {
    await abrirTela(tester);
    await tester.enterText(campoTitulo, 'Risoto');
    await tocar(tester, find.text('Bebidas'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Passo 2 de 3'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Risoto'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bebidas'))
          .selected,
      isTrue,
    );
  });

  testWidgets('app abre a tela pela tela inicial', (tester) async {
    await tester.pumpWidget(const ReceitouApp());
    await tester.tap(find.text('Nova Receita'));
    await tester.pumpAndSettle();
    expect(find.text('Informações Básicas'), findsOneWidget);
  });
}
