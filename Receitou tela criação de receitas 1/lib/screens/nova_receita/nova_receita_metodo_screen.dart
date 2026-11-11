import 'package:flutter/material.dart';

import 'nova_receita_fluxo.dart';
import 'widgets/indicador_passos.dart';

/// Passo 3 — provisório até ter spec própria; existe para a navegação do passo 2.
class NovaReceitaMetodoScreen extends StatelessWidget {
  final NovaReceitaFluxo fluxo;

  const NovaReceitaMetodoScreen({super.key, required this.fluxo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Receita')),
      body: const Column(
        children: [
          IndicadorPassos(passoAtual: 3),
          Expanded(child: Center(child: Text('Método'))),
        ],
      ),
    );
  }
}
