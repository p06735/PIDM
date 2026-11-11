import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:receitou/models/receita_rascunho.dart';
import 'package:receitou/screens/nova_receita/nova_receita_fluxo.dart';
import 'package:receitou/screens/nova_receita/nova_receita_informacoes_screen.dart';
import 'package:receitou/screens/nova_receita/nova_receita_ingredientes_screen.dart';
import 'package:receitou/theme/app_theme.dart';

/// Monta um app com um botão "abrir" que empurra a tela indicada.
Future<void> montar(WidgetTester tester, WidgetBuilder tela) async {
  tester.view
    ..physicalSize = const Size(412, 915)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: tela)),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

/// Abre o Passo 2 diretamente, com o fluxo informado.
Future<NovaReceitaFluxo> abrirPasso2(
  WidgetTester tester, {
  List<Ingrediente>? ingredientes,
}) async {
  final fluxo = NovaReceitaFluxo(
    rascunho: ReceitaRascunho(titulo: 'Bolo', ingredientes: ingredientes),
  );
  await montar(tester, (_) => NovaReceitaIngredientesScreen(fluxo: fluxo));
  return fluxo;
}

/// Abre o Passo 1, preenche o título e avança para o Passo 2.
Future<void> abrirPeloPasso1(WidgetTester tester) async {
  await montar(tester, (_) => NovaReceitaInformacoesScreen());
  await tester.enterText(find.byType(TextField).first, 'Risoto');
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
}

Finder qtd(int linha) => find.byType(TextField).at(linha * 2);
Finder desc(int linha) => find.byType(TextField).at(linha * 2 + 1);
Finder get lixeiras => find.byTooltip('Remover ingrediente');

bool temFoco(WidgetTester tester, Finder campo) =>
    tester.widget<TextField>(campo).focusNode!.hasFocus;

String texto(WidgetTester tester, Finder campo) =>
    tester.widget<TextField>(campo).controller!.text;

const farinha = Ingrediente(
  quantidade: '2',
  descricao: 'Xícaras de Farinha de Trigo',
);
const sal = Ingrediente(quantidade: '1/2', descricao: 'Colher de chá de Sal');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('CA01 estado inicial', (tester) async {
    await abrirPasso2(tester);
    expect(find.text('Passo 2 de 3'), findsOneWidget);
    expect(find.text('Ingredientes'), findsOneWidget);
    expect(find.text('Lista de Ingredientes'), findsOneWidget);
    expect(find.text('Qtd'), findsOneWidget);
    expect(find.text('Ex: Gramas de Manteiga...'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(lixeiras, findsNothing);
  });

  testWidgets('CA02 mostra ingredientes do rascunho + linha vazia', (
    tester,
  ) async {
    await abrirPasso2(tester, ingredientes: [farinha, sal]);
    expect(texto(tester, qtd(0)), '2');
    expect(texto(tester, desc(0)), 'Xícaras de Farinha de Trigo');
    expect(texto(tester, qtd(1)), '1/2');
    expect(find.byType(TextField), findsNWidgets(6));
    expect(lixeiras, findsNWidgets(2));
  });

  testWidgets('CA03/CA04 voltar ao Passo 1 e avançar mantém os dados', (
    tester,
  ) async {
    await abrirPeloPasso1(tester);
    await tester.enterText(qtd(0), '2');
    await tester.enterText(desc(0), 'Ovos');
    await tester.enterText(qtd(1), '3'); // linha incompleta
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Informações Básicas'), findsOneWidget);
    expect(find.text('Risoto'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(texto(tester, desc(0)), 'Ovos');
    expect(texto(tester, qtd(1)), '3');
  });

  testWidgets('CA03 voltar do sistema volta ao Passo 1', (tester) async {
    await abrirPeloPasso1(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Informações Básicas'), findsOneWidget);
    expect(find.text('Descartar receita?'), findsNothing);
  });

  testWidgets('avisos aparecem acima do rodapé', (tester) async {
    await abrirPasso2(tester, ingredientes: [farinha]);
    await tester.tap(lixeiras.first);
    await tester.pumpAndSettle();
    final aviso = tester.getRect(find.byType(SnackBar));
    final continuar = tester.getRect(find.text('Continuar'));
    expect(aviso.bottom, lessThanOrEqualTo(continuar.top));
  });

  testWidgets('rodapé sobe acima do teclado', (tester) async {
    await abrirPasso2(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    final continuar = tester.getRect(find.text('Continuar'));
    expect(continuar.bottom, lessThanOrEqualTo(915 - 300));
  });

  testWidgets('CA05 fechar sem alterações fecha o fluxo', (tester) async {
    await abrirPasso2(tester);
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('CA06/CA07 cancelar mantém e descartar fecha', (tester) async {
    await abrirPasso2(tester);
    await tester.enterText(desc(0), 'Ovos');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(texto(tester, desc(0)), 'Ovos');

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('CA06/CA07 alteração do Passo 1 pede confirmação; salvar fecha '
      'o fluxo inteiro', (tester) async {
    await abrirPeloPasso1(tester);
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsOneWidget);

    await tester.tap(find.text('Salvar rascunho'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
    expect(find.text('Rascunho salvo'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isNotEmpty);
  });

  testWidgets('CA09 digitar na linha vazia cria outra; limpar remove', (
    tester,
  ) async {
    await abrirPasso2(tester);
    await tester.enterText(qtd(0), '2');
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(4));
    expect(lixeiras, findsOneWidget);

    await tester.enterText(qtd(0), '');
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(lixeiras, findsNothing);
  });

  testWidgets('CA10 "próximo" do teclado avança entre os campos', (
    tester,
  ) async {
    await abrirPasso2(tester);
    await tester.enterText(qtd(0), '2');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(temFoco(tester, desc(0)), isTrue);

    await tester.enterText(desc(0), 'Ovos');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(temFoco(tester, qtd(1)), isTrue);
  });

  testWidgets('CA11 limites de caracteres', (tester) async {
    await abrirPasso2(tester);
    await tester.enterText(qtd(0), 'a' * 11);
    await tester.enterText(desc(0), 'b' * 81);
    await tester.pump();
    expect(texto(tester, qtd(0)).length, 10);
    expect(texto(tester, desc(0)).length, 80);
  });

  testWidgets('CA13/CA14 remover e desfazer', (tester) async {
    final fluxo = await abrirPasso2(tester, ingredientes: [farinha, sal]);
    await tester.tap(lixeiras.first);
    await tester.pumpAndSettle();
    expect(find.text('Xícaras de Farinha de Trigo'), findsNothing);
    expect(find.text('Ingrediente removido'), findsOneWidget);
    expect(fluxo.rascunho.ingredientes.single.descricao, sal.descricao);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(texto(tester, desc(0)), farinha.descricao);
    expect(texto(tester, desc(1)), sal.descricao);
    expect(fluxo.rascunho.ingredientes, hasLength(2));
  });

  testWidgets('CA15 adicionar foca a linha vazia sem criar outra', (
    tester,
  ) async {
    await abrirPasso2(tester, ingredientes: [farinha]);
    await tester.tap(find.text('Adicionar Ingrediente'));
    await tester.pump();
    expect(temFoco(tester, qtd(1)), isTrue);
    expect(find.byType(TextField), findsNWidgets(4));
  });

  testWidgets('CA16 limite de 50 ingredientes', (tester) async {
    await abrirPasso2(tester, ingredientes: List.filled(50, sal));
    expect(find.byType(TextField), findsNWidgets(100));
    final botao = find.text('Adicionar Ingrediente');
    await tester.ensureVisible(botao);
    await tester.pumpAndSettle();
    await tester.tap(botao);
    await tester.pump();
    expect(
      find.text('Você atingiu o limite de 50 ingredientes.'),
      findsOneWidget,
    );
  });

  testWidgets('CA17 continuar grava a lista e abre o Passo 3', (tester) async {
    final fluxo = await abrirPasso2(tester);
    await tester.enterText(desc(0), '  Sal a gosto ');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Passo 3 de 3'), findsOneWidget);
    final ingrediente = fluxo.rascunho.ingredientes.single;
    expect(ingrediente.quantidade, '');
    expect(ingrediente.descricao, 'Sal a gosto');
  });

  testWidgets('CA18 continuar sem ingredientes mostra erro', (tester) async {
    await abrirPasso2(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    expect(find.text('Adicione pelo menos um ingrediente.'), findsOneWidget);
    expect(temFoco(tester, desc(0)), isTrue);
    expect(find.text('Passo 3 de 3'), findsNothing);
  });

  testWidgets('CA19 linha incompleta mostra erro até ser descrita', (
    tester,
  ) async {
    await abrirPasso2(tester, ingredientes: [farinha]);
    await tester.enterText(qtd(1), '3');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Descreva o ingrediente.'), findsOneWidget);
    expect(find.text('Passo 3 de 3'), findsNothing);

    await tester.enterText(desc(1), 'Ovos');
    await tester.pump();
    expect(find.text('Descreva o ingrediente.'), findsNothing);
  });

  testWidgets('CA08 tocar num campo dá foco (borda terracota) e abre o '
      'teclado', (tester) async {
    await abrirPasso2(tester);
    await tester.tap(qtd(0));
    await tester.pump();
    final decorador = tester.widget<InputDecorator>(
      find.descendant(of: qtd(0), matching: find.byType(InputDecorator)),
    );
    expect(decorador.isFocused, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('CA12 descrição longa quebra em várias linhas e o campo cresce', (
    tester,
  ) async {
    await abrirPasso2(tester, ingredientes: [farinha, sal]);
    final alturaCurta = tester.getSize(desc(1)).height;
    await tester.enterText(
      desc(1),
      'Colher de chá de Sal marinho grosso moído',
    );
    await tester.pump();
    expect(tester.getSize(desc(1)).height, greaterThan(alturaCurta));
    expect(
      tester.getTopLeft(qtd(1)).dy,
      tester.getTopLeft(desc(1)).dy,
      reason: 'Qtd alinhado ao topo da linha',
    );
  });

  testWidgets('CA20 tocar no indicador de passos não muda nada', (
    tester,
  ) async {
    await abrirPasso2(tester);
    await tester.tap(find.text('Informações'));
    await tester.tap(find.text('Método'));
    await tester.pumpAndSettle();
    expect(find.text('Passo 2 de 3'), findsOneWidget);
    expect(find.text('Lista de Ingredientes'), findsOneWidget);
  });

  test('ingredientes entram no JSON do rascunho', () {
    final original = ReceitaRascunho(titulo: 'Bolo', ingredientes: [farinha]);
    final copia = ReceitaRascunho.fromJson(original.toJson());
    expect(copia.ingredientes.single.quantidade, '2');
    expect(copia.ingredientes.single.descricao, farinha.descricao);
    expect(ReceitaRascunho.fromJson({'titulo': 'x'}).ingredientes, isEmpty);
  });
}
