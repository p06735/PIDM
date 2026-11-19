import 'package:flutter/material.dart';

import 'screens/perfil/perfil_screen.dart';
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
      // Perfil é a tela inicial; "Criar Receita" abre o fluxo Nova Receita.
      home: PerfilScreen(),
    );
  }
}
