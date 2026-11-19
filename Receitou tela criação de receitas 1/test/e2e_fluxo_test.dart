// Testes de ponta a ponta: o app inteiro, do Perfil até publicar (T01–T08).
// IDs iguais aos da tabela de testes do relatório.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:receitou/main.dart';
import 'package:receitou/screens/nova_receita/nova_receita_fluxo.dart';
import 'package:receitou/screens/nova_receita/nova_receita_metodo_screen.dart';
import 'package:receitou/theme/app_theme.dart';

Future<void> abrirApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(412, 915)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ReceitouApp());
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Finder campo(String placeholder) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == placeholder,
);

const hintTitulo = 'Ex: Risoto de Cogumelos Selvagens';
const hintIngrediente = 'Ex: Gramas de Manteiga...';
const hintPasso = 'Descreva as ações necessárias para este passo...';

/// Perfil → Passo 3 com título e um ingrediente preenchidos.
Future<void> irAtePasso3(WidgetTester tester, {String titulo = 'Salada'}) async {
  await tocar(tester, find.text('Criar Receita'));
  await tester.enterText(campo(hintTitulo), titulo);
  await tocar(tester, find.text('Continuar'));
  await tester.enterText(campo(hintIngrediente), 'Grão-de-bico');
  await tester.pump();
  await tocar(tester, find.text('Continuar'));
  expect(find.text('Modo de Preparo'), findsOneWidget);
}

String postagens(WidgetTester tester) {
  final rotulo = find.text('POSTAGENS');
  final coluna = find.ancestor(of: rotulo, matching: find.byType(Column)).first;
  final textos = tester
      .widgetList<Text>(find.descendant(of: coluna, matching: find.byType(Text)))
      .map((t) => t.data)
      .toList();
  return textos.first!;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('T01 caminho do roteiro: Perfil → criar → publicar', (
    tester,
  ) async {
    await abrirApp(tester);
    expect(postagens(tester), '12');
    await irAtePasso3(tester, titulo: 'Salada de Grão-de-Bico');
    await tester.enterText(campo(hintPasso), 'Corte os vegetais em cubos.');
    await tocar(tester, find.text('Publicar'));

    expect(find.text('Modo de Preparo'), findsNothing);
    expect(find.text('Receita publicada!'), findsOneWidget);
    expect(postagens(tester), '13');
    expect(find.text('Salada de Grão-de-Bico'), findsOneWidget);
    expect(find.text('Prato Principal'), findsOneWidget);
  });

  testWidgets('T02 voltar no meio mantém os dados; X descarta', (tester) async {
    await abrirApp(tester);
    await irAtePasso3(tester, titulo: 'Bolo Teste');
    await tester.enterText(campo(hintPasso), 'Misture tudo.');
    await tocar(tester, find.text('Voltar'));

    expect(find.text('Lista de Ingredientes'), findsOneWidget);
    expect(find.text('Grão-de-bico'), findsOneWidget);

    await tocar(tester, find.text('Continuar'));
    expect(find.text('Misture tudo.'), findsOneWidget);

    await tocar(tester, find.byTooltip('Fechar'));
    expect(find.text('Descartar receita?'), findsOneWidget);
    await tocar(tester, find.text('Descartar'));

    expect(find.text('Criar Receita'), findsOneWidget);
    expect(find.text('Bolo Teste'), findsNothing);
    expect(postagens(tester), '12');
  });

  testWidgets('T03 campo vazio: publicar sem passo descrito', (tester) async {
    await abrirApp(tester);
    await irAtePasso3(tester);
    await tocar(tester, find.text('Adicionar passo'));
    await tocar(tester, find.text('Publicar'));

    expect(find.text('Descreva pelo menos um passo.'), findsOneWidget);
    expect(find.text('Modo de Preparo'), findsOneWidget);

    // Preenche só o 2º cartão: o 1º (vazio) é descartado ao publicar.
    await tester.enterText(campo(hintPasso).at(1), 'Sirva gelado.');
    await tester.pump();
    expect(find.text('Descreva pelo menos um passo.'), findsNothing);
    await tocar(tester, find.text('Publicar'));
    expect(find.text('Receita publicada!'), findsOneWidget);
    expect(postagens(tester), '13');
  });

  testWidgets('T04 voltar e mudar um valor: título novo é publicado', (
    tester,
  ) async {
    await abrirApp(tester);
    await irAtePasso3(tester, titulo: 'Torta Antiga');
    await tester.enterText(campo(hintPasso), 'Asse por 40 minutos.');
    await tocar(tester, find.text('Voltar'));
    await tocar(tester, find.text('Voltar'));

    expect(find.text('Informações Básicas'), findsOneWidget);
    await tester.enterText(campo(hintTitulo), 'Torta Nova');
    await tocar(tester, find.text('Sobremesa'));
    await tocar(tester, find.text('Continuar'));
    await tocar(tester, find.text('Continuar'));
    expect(find.text('Asse por 40 minutos.'), findsOneWidget);
    await tocar(tester, find.text('Publicar'));

    expect(find.text('Torta Nova'), findsOneWidget);
    expect(find.text('Torta Antiga'), findsNothing);
    expect(find.text('Sobremesa'), findsOneWidget);
  });

  testWidgets('T05 toque duplo rápido em Publicar publica uma vez', (
    tester,
  ) async {
    await abrirApp(tester);
    await irAtePasso3(tester, titulo: 'Pão Duplo');
    await tester.enterText(campo(hintPasso), 'Sove a massa.');
    final publicar = find.text('Publicar');
    await tester.ensureVisible(publicar);
    await tester.tap(publicar);
    await tester.tap(publicar, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Pão Duplo'), findsOneWidget);
    expect(postagens(tester), '13');
  });

  testWidgets('T06 toque duplo rápido em Criar Receita abre um fluxo só', (
    tester,
  ) async {
    await abrirApp(tester);
    final criar = find.text('Criar Receita');
    await tester.tap(criar);
    await tester.tap(criar, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Informações Básicas'), findsOneWidget);

    await tocar(tester, find.byTooltip('Fechar'));
    expect(find.text('Informações Básicas'), findsNothing);
    expect(find.text('Criar Receita'), findsOneWidget);
  });

  testWidgets('T07 aba Salvas e coração', (tester) async {
    await abrirApp(tester);
    await tocar(tester, find.text('Salvas'));
    expect(find.text('Pão de Fermentação Natural Básico'), findsOneWidget);
    expect(find.text('Tagliatelle Artesanal com Pomodoro'), findsNothing);
    expect(find.text('Criar Receita'), findsNothing);

    await tocar(tester, find.byTooltip('Remover dos salvos'));
    expect(find.textContaining('Nenhuma receita salva ainda'), findsOneWidget);

    await tocar(tester, find.text('Minhas Receitas'));
    expect(find.text('Criar Receita'), findsOneWidget);
  });

  testWidgets('T08 passo com foto e sem texto não publica', (tester) async {
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NovaReceitaMetodoScreen(
          fluxo: NovaReceitaFluxo(),
          selecionarMidias: () async => [
            XFile('a.png', name: 'a.png'),
            XFile('b.gif', name: 'b.gif'),
          ],
        ),
      ),
    );
    await tocar(tester, find.text('Adicionar foto ou vídeo'));
    expect(find.text('Mais fotos'), findsOneWidget);
    expect(
      find.text('Use fotos JPG, PNG ou WEBP, ou vídeos MP4 ou MOV.'),
      findsOneWidget,
    );

    await tocar(tester, find.text('Publicar'));
    expect(find.text('Descreva este passo.'), findsOneWidget);
    expect(find.text('Modo de Preparo'), findsOneWidget);

    await tester.enterText(campo(hintPasso), 'Pique a cebola.');
    await tester.pump();
    expect(find.text('Descreva este passo.'), findsNothing);
  });
}
