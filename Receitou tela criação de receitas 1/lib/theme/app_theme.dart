import 'package:flutter/material.dart';

class AppColors {
  static const terracota = Color(0xFFA9531F);
  static const fundo = Color(0xFFFBF7F3);
  static const superficie = Color(0xFFF4EDE7);
  static const borda = Color(0xFFE3D6CB);
  static const texto = Color(0xFF2B211C);
  static const textoSecundario = Color(0xFF7F736B);
  static const erro = Color(0xFFC62828);
}

class AppTheme {
  static const fonteSerifada = 'serif';

  static ThemeData get light {
    OutlineInputBorder borda(Color cor, [double largura = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cor, width: largura),
        );

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracota,
        primary: AppColors.terracota,
        surface: AppColors.fundo,
        error: AppColors.erro,
      ),
      scaffoldBackgroundColor: AppColors.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundo,
        foregroundColor: AppColors.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fonteSerifada,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        hintStyle: const TextStyle(color: AppColors.textoSecundario),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: borda(AppColors.borda),
        focusedBorder: borda(AppColors.terracota, 1.5),
        errorBorder: borda(AppColors.erro),
        focusedErrorBorder: borda(AppColors.erro, 1.5),
      ),
    );
  }
}
