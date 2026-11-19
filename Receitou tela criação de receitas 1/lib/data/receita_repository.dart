import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/receita_rascunho.dart';

/// Receita como aparece nos cartões do Perfil.
class ReceitaResumo {
  final String id;
  final String titulo;
  final String categoria;
  final String? dificuldade;
  final String? tempo;
  final int curtidas;
  final String? foto;
  final bool exemplo;

  const ReceitaResumo({
    required this.id,
    required this.titulo,
    required this.categoria,
    this.dificuldade,
    this.tempo,
    this.curtidas = 0,
    this.foto,
    this.exemplo = false,
  });

  /// 1200 → "1.2k"; 850 → "850".
  String get curtidasFormatadas {
    if (curtidas < 1000) return '$curtidas';
    final k = curtidas / 1000;
    final texto = k == k.roundToDouble()
        ? k.toStringAsFixed(0)
        : k.toStringAsFixed(1);
    return '${texto}k';
  }
}

/// Receitas publicadas (local) + receitas de exemplo do Figma.
class ReceitaRepository {
  static const _chavePublicadas = 'receitas_publicadas';
  static const _chaveSalvas = 'receitas_salvas';

  static const exemplos = [
    ReceitaResumo(
      id: 'exemplo_pao',
      titulo: 'Pão de Fermentação Natural Básico',
      categoria: 'Pães',
      dificuldade: 'Demorado',
      tempo: '24h',
      curtidas: 1200,
      foto: 'assets/img/pao_fermentacao.png',
      exemplo: true,
    ),
    ReceitaResumo(
      id: 'exemplo_tagliatelle',
      titulo: 'Tagliatelle Artesanal com Pomodoro',
      categoria: 'Massas',
      dificuldade: 'Médio',
      tempo: '1h 30m',
      curtidas: 850,
      foto: 'assets/img/tagliatelle.png',
      exemplo: true,
    ),
  ];

  /// Publica a receita e devolve o id gerado.
  Future<String> publicar(ReceitaRascunho receita) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chavePublicadas) ?? [];
    final id = 'pub_${DateTime.now().microsecondsSinceEpoch}';
    final json = receita.toJson()
      ..['id'] = id
      ..['atualizadoEm'] = DateTime.now().toIso8601String();
    lista.insert(0, jsonEncode(json));
    await prefs.setStringList(_chavePublicadas, lista);
    return id;
  }

  /// Publicadas (mais nova primeiro) seguidas dos exemplos.
  Future<List<ReceitaResumo>> minhasReceitas() async {
    final prefs = await SharedPreferences.getInstance();
    final publicadas = [
      for (final texto in prefs.getStringList(_chavePublicadas) ?? const [])
        ReceitaRascunho.fromJson(jsonDecode(texto) as Map<String, dynamic>),
    ];
    return [
      for (final r in publicadas)
        ReceitaResumo(
          id: r.id!,
          titulo: r.titulo,
          categoria: r.categoria.rotulo,
          foto: r.fotoCapa,
        ),
      ...exemplos,
    ];
  }

  Future<Set<String>> salvas() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chaveSalvas);
    // Primeira execução: o pão já vem salvo, como no Figma.
    return lista?.toSet() ?? {'exemplo_pao'};
  }

  Future<void> definirSalva(String id, bool salva) async {
    final atual = await salvas();
    salva ? atual.add(id) : atual.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chaveSalvas, atual.toList());
  }
}
