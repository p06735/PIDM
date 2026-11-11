import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Título serifado + subtítulo no topo do conteúdo de cada passo.
class CabecalhoPasso extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const CabecalhoPasso({
    super.key,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontFamily: AppTheme.fonteSerifada,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.texto,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitulo,
          style: const TextStyle(fontSize: 15, color: AppColors.texto),
        ),
      ],
    );
  }
}

/// Rodapé fixo dos passos: ação secundária (texto) à esquerda e
/// "Continuar →" à direita.
///
/// Deve ser usado como `bottomNavigationBar` do Scaffold, para que os avisos
/// (SnackBar) apareçam acima dele. [teclado] é a altura do teclado aberto,
/// para o rodapé subir junto com ele.
class RodapeFluxo extends StatelessWidget {
  final String rotuloSecundario;
  final IconData? iconeSecundario;
  final VoidCallback onSecundario;
  final VoidCallback onContinuar;
  final double teclado;

  const RodapeFluxo({
    super.key,
    required this.rotuloSecundario,
    this.iconeSecundario,
    required this.onSecundario,
    required this.onContinuar,
    required this.teclado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.fundo,
          border: Border(top: BorderSide(color: AppColors.borda)),
        ),
        child: SafeArea(
          top: false,
          maintainBottomViewPadding: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onSecundario,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.texto,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconeSecundario != null) ...[
                          Icon(iconeSecundario, size: 18),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            rotuloSecundario,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onContinuar,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.terracota,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Continuar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
