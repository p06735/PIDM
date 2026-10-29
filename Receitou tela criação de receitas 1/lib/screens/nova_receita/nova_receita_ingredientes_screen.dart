import 'package:flutter/material.dart';

import '../../models/receita_rascunho.dart';
import 'widgets/indicador_passos.dart';

/// Passo 2 — provisório até ter spec própria; existe para a navegação do passo 1.
class NovaReceitaIngredientesScreen extends StatelessWidget {
  final ReceitaRascunho rascunho;

  const NovaReceitaIngredientesScreen({super.key, required this.rascunho});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Receita')),
      body: const Column(
        children: [
          IndicadorPassos(passoAtual: 2),
          Expanded(child: Center(child: Text('Ingredientes'))),
        ],
      ),
    );
  }
}
