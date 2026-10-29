import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Indicador do fluxo de 3 passos. Não é tocável.
class IndicadorPassos extends StatelessWidget {
  static const passos = ['Informações', 'Ingredientes', 'Método'];

  /// Passo ativo, começando em 1.
  final int passoAtual;

  const IndicadorPassos({super.key, required this.passoAtual});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < passos.length; i++)
                Text(
                  passos[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        i + 1 == passoAtual ? FontWeight.w700 : FontWeight.w400,
                    color: i + 1 == passoAtual
                        ? AppColors.terracota
                        : AppColors.textoSecundario,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: passoAtual / passos.length,
              minHeight: 6,
              color: AppColors.terracota,
              backgroundColor: AppColors.borda,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Passo $passoAtual de ${passos.length}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
