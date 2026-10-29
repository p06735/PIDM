import 'package:flutter/material.dart';

import 'screens/nova_receita/nova_receita_informacoes_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ReceitouApp());
}

class ReceitouApp extends StatelessWidget {
  const ReceitouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receitou',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const InicioScreen(),
    );
  }
}

/// Tela inicial provisória: ponto de entrada para "Nova Receita".
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receitou')),
      body: Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Nova Receita'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NovaReceitaInformacoesScreen()),
          ),
        ),
      ),
    );
  }
}
