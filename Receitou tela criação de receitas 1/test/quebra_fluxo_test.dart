// Casos de teste que tentam quebrar o fluxo de "Nova Receita" (Q01–Q28).
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:receitou/models/receita_rascunho.dart';
import 'package:receitou/screens/nova_receita/nova_receita_fluxo.dart';
import 'package:receitou/screens/nova_receita/nova_receita_informacoes_screen.dart';
import 'package:receitou/screens/nova_receita/nova_receita_ingredientes_screen.dart';
import 'package:receitou/screens/nova_receita/nova_receita_metodo_screen.dart';
import 'package:receitou/theme/app_theme.dart';

Future<void> montar(
  WidgetTester tester,
  WidgetBuilder tela, {
  Size tamanho = const Size(412, 915),
}) async {
  tester.view
    ..physicalSize = tamanho
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

Future<void> abrirPasso1(WidgetTester tester, {SelecionarImagem? imagem}) =>
    montar(
      tester,
      (_) => NovaReceitaInformacoesScreen(selecionarImagem: imagem),
    );

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

Future<void> avancarParaPasso2(WidgetTester tester) async {
  await tester.enterText(campoTitulo, 'Risoto');
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
}

Finder get campoTitulo => find.byType(TextField).first;
Finder qtd(int linha) => find.byType(TextField).at(linha * 2);
Finder desc(int linha) => find.byType(TextField).at(linha * 2 + 1);
Finder get lixeiras => find.byTooltip('Remover ingrediente');

String texto(WidgetTester tester, Finder campo) =>
    tester.widget<TextField>(campo).controller!.text;

List<Ingrediente> itens(int n) => [
  for (var i = 0; i < n; i++)
    Ingrediente(quantidade: '1', descricao: 'Item $i'),
];

Future<int> rascunhosSalvos() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getKeys().where((k) => k.startsWith('rascunho_')).length;
}

SelecionarImagem imagem(String nome, int bytes) =>
    (_) async => XFile.fromData(Uint8List(bytes), name: nome, path: nome);

Future<void> escolherFoto(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Adicionar Foto de Capa'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Adicionar Foto de Capa'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Escolher da galeria'));
  await tester.pumpAndSettle();
}

const erroFoto = 'Use uma imagem JPG ou PNG de até 10 MB.';
const dezMB = 10 * 1024 * 1024;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Q01 toque duplo em Continuar no Passo 1 abre um só Passo 2', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Risoto');
    await tester.tap(find.text('Continuar'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Continuar').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(
      find.byType(NovaReceitaIngredientesScreen, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Q02 toque duplo em Continuar no Passo 2 abre um só Passo 3', (
    tester,
  ) async {
    await abrirPasso2(tester, ingredientes: itens(1));
    await tester.tap(find.text('Continuar'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Continuar').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(
      find.byType(NovaReceitaMetodoScreen, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Q03 toque duplo no X com alterações abre no máximo um diálogo', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byTooltip('Fechar').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog).evaluate().length, lessThanOrEqualTo(1));
    expect(find.text('abrir'), findsNothing);
  });

  testWidgets('Q04 título só com espaços é tratado como vazio', (tester) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, '     ');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Dê um nome à sua receita.'), findsOneWidget);
    expect(find.text('Passo 2 de 3'), findsNothing);
  });

  testWidgets('Q05 título "  ab  " conta só 2 caracteres', (tester) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, '  ab  ');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(
      find.text('O título precisa ter pelo menos 3 caracteres.'),
      findsOneWidget,
    );
  });

  testWidgets('Q06 título com 2 emojis conta como 2 caracteres', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, '🍰🍰');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(
      find.text('O título precisa ter pelo menos 3 caracteres.'),
      findsOneWidget,
    );
    expect(find.text('Passo 2 de 3'), findsNothing);
  });

  testWidgets('Q07 colar descrição com quebra de linha vira uma linha só', (
    tester,
  ) async {
    await abrirPasso2(tester);
    await tester.enterText(desc(0), 'Xícaras de\nFarinha de Trigo');
    await tester.pump();
    expect(texto(tester, desc(0)), 'Xícaras de Farinha de Trigo');
  });

  testWidgets('Q08 colar 200 caracteres na descrição mantém 80', (
    tester,
  ) async {
    await abrirPasso2(tester);
    await tester.enterText(desc(0), 'x' * 200);
    await tester.pump();
    expect(texto(tester, desc(0)).length, 80);
  });

  testWidgets('Q09 quantidade só com espaços não bloqueia o Continuar', (
    tester,
  ) async {
    await abrirPasso2(tester, ingredientes: itens(1));
    await tester.enterText(qtd(1), '   ');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Passo 3 de 3'), findsOneWidget);
  });

  testWidgets('Q10 descrição só com espaços conta como incompleta', (
    tester,
  ) async {
    await abrirPasso2(tester);
    await tester.enterText(qtd(0), '2');
    await tester.enterText(desc(0), '    ');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Descreva o ingrediente.'), findsOneWidget);
  });

  testWidgets('Q11 remover todos os ingredientes e continuar mostra erro', (
    tester,
  ) async {
    await abrirPasso2(tester, ingredientes: itens(2));
    await tester.tap(lixeiras.first);
    await tester.pumpAndSettle();
    await tester.tap(lixeiras.first);
    await tester.pumpAndSettle();
    expect(lixeiras, findsNothing);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Adicione pelo menos um ingrediente.'), findsOneWidget);
  });

  testWidgets('Q12 "Desfazer" tocado depois de voltar ao Passo 1 não quebra', (
    tester,
  ) async {
    await montar(tester, (_) => NovaReceitaInformacoesScreen());
    await avancarParaPasso2(tester);
    await tester.enterText(desc(0), 'Ovos');
    await tester.pump();
    await tester.tap(lixeiras.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    if (find.text('Desfazer').evaluate().isNotEmpty) {
      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Informações Básicas'), findsOneWidget);
  });

  testWidgets('Q13 desfazer devolve o item à posição original mesmo após '
      'adicionar outro', (tester) async {
    await abrirPasso2(tester, ingredientes: itens(3));
    await tester.tap(lixeiras.at(1));
    await tester.pumpAndSettle();
    await tester.enterText(desc(2), 'Novo');
    await tester.pump();
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(
      [for (var i = 0; i < 4; i++) texto(tester, desc(i))],
      ['Item 0', 'Item 1', 'Item 2', 'Novo'],
    );
  });

  testWidgets('Q14 linha do meio esvaziada é descartada ao continuar', (
    tester,
  ) async {
    final fluxo = await abrirPasso2(tester, ingredientes: itens(3));
    await tester.enterText(qtd(1), '');
    await tester.enterText(desc(1), '');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Passo 3 de 3'), findsOneWidget);
    expect(fluxo.rascunho.ingredientes.map((i) => i.descricao), [
      'Item 0',
      'Item 2',
    ]);
  });

  testWidgets('Q15 desfazer no limite de 50 não ultrapassa o limite', (
    tester,
  ) async {
    final fluxo = await abrirPasso2(tester, ingredientes: itens(50));
    await tester.tap(lixeiras.first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Novo');
    await tester.pump();
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(fluxo.rascunho.ingredientes.length, lessThanOrEqualTo(50));
    expect(find.byType(TextField), findsNWidgets(100));
  });

  testWidgets('Q16 digitar 50 ingredientes um a um respeita o limite', (
    tester,
  ) async {
    await abrirPasso2(tester);
    for (var i = 0; i < 50; i++) {
      await tester.enterText(desc(i), 'Item $i');
      await tester.pump();
    }
    expect(find.byType(TextField), findsNWidgets(100));
    await tester.ensureVisible(find.text('Adicionar Ingrediente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar Ingrediente'));
    await tester.pump();
    expect(
      find.text('Você atingiu o limite de 50 ingredientes.'),
      findsOneWidget,
    );
  });

  testWidgets('Q17 salvar rascunho duas vezes guarda um só rascunho', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.text('Salvar Rascunho'));
    await tester.tap(find.text('Salvar Rascunho'));
    await tester.pumpAndSettle();
    expect(await rascunhosSalvos(), 1);
  });

  testWidgets('Q18 alterar depois de salvar pede confirmação no X', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.text('Salvar Rascunho'));
    await tester.pumpAndSettle();
    await tester.enterText(campoTitulo, 'Bolo de cenoura');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsOneWidget);
  });

  testWidgets('Q19 alterar e voltar ao texto salvo fecha sem diálogo', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.text('Salvar Rascunho'));
    await tester.pumpAndSettle();
    await tester.enterText(campoTitulo, 'Bolos');
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('Q20 alteração só no Passo 2 é detectada pelo X do Passo 1', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Risoto');
    await tester.tap(find.text('Salvar Rascunho'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(desc(0), 'Arroz arbóreo');
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsOneWidget);
  });

  testWidgets('Q21 voltar do sistema no Passo 1 com alterações pede '
      'confirmação', (tester) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsOneWidget);
  });

  testWidgets('Q22 voltar do sistema com o diálogo aberto fecha só o diálogo', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await tester.enterText(campoTitulo, 'Bolo');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Descartar receita?'), findsNothing);
    expect(texto(tester, campoTitulo), 'Bolo');
  });

  testWidgets('Q23 foto com extensão maiúscula (.JPG) é aceita', (
    tester,
  ) async {
    await abrirPasso1(tester, imagem: imagem('FOTO.JPG', 10));
    await escolherFoto(tester);
    expect(find.text(erroFoto), findsNothing);
    expect(find.byTooltip('Remover foto'), findsOneWidget);
  });

  testWidgets('Q24 foto com extensão dupla (.png.gif) é rejeitada', (
    tester,
  ) async {
    await abrirPasso1(tester, imagem: imagem('capa.png.gif', 10));
    await escolherFoto(tester);
    expect(find.text(erroFoto), findsOneWidget);
    expect(find.byTooltip('Remover foto'), findsNothing);
  });

  testWidgets('Q25a foto com exatamente 10 MB é aceita', (tester) async {
    await abrirPasso1(tester, imagem: imagem('capa.png', dezMB));
    await escolherFoto(tester);
    expect(find.byTooltip('Remover foto'), findsOneWidget);
  });

  testWidgets('Q25b foto com 10 MB + 1 byte é rejeitada', (tester) async {
    await abrirPasso1(tester, imagem: imagem('capa.png', dezMB + 1));
    await escolherFoto(tester);
    expect(find.text(erroFoto), findsOneWidget);
  });

  testWidgets('Q26 cancelar a escolha da foto não muda nada', (tester) async {
    await abrirPasso1(tester, imagem: (_) async => null);
    await escolherFoto(tester);
    expect(find.text('Adicionar Foto de Capa'), findsOneWidget);
    expect(find.text(erroFoto), findsNothing);
  });

  testWidgets('Q27 voltar, apagar o título e continuar é bloqueado', (
    tester,
  ) async {
    await abrirPasso1(tester);
    await avancarParaPasso2(tester);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    await tester.enterText(campoTitulo, '');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Dê um nome à sua receita.'), findsOneWidget);
    expect(find.text('Passo 2 de 3'), findsNothing);
  });

  testWidgets('Q28 fonte do sistema em 200% numa tela de 320 px não corta '
      'nada nos dois passos', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await montar(
      tester,
      (_) => NovaReceitaInformacoesScreen(),
      tamanho: const Size(320, 640),
    );
    await avancarParaPasso2(tester);
    await tester.enterText(qtd(0), '1/2');
    await tester.enterText(desc(0), 'Colher de chá de Sal');
    await tester.pump();
    expect(find.text('Passo 2 de 3'), findsOneWidget);
  });
}
