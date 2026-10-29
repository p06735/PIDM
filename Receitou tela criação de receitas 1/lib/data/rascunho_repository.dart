import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/receita_rascunho.dart';

/// Persiste rascunhos localmente no dispositivo.
class RascunhoRepository {
  static const _prefixo = 'rascunho_';

  Future<void> salvar(ReceitaRascunho rascunho) async {
    rascunho.id ??= DateTime.now().microsecondsSinceEpoch.toString();
    rascunho.atualizadoEm = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefixo${rascunho.id}',
      jsonEncode(rascunho.toJson()),
    );
  }

  Future<ReceitaRascunho?> carregar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_prefixo$id');
    if (json == null) return null;
    return ReceitaRascunho.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
}
