import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Mostra uma imagem do app (`assets/...`), um arquivo local ou, na web,
/// uma URL blob: do image_picker.
class ImagemLocal extends StatelessWidget {
  final String caminho;
  final BoxFit fit;

  const ImagemLocal(this.caminho, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    Widget erro(BuildContext _, Object _, StackTrace? _) =>
        const ColoredBox(color: Color(0x11000000));
    if (caminho.startsWith('assets/')) {
      return Image.asset(caminho, fit: fit, errorBuilder: erro);
    }
    if (kIsWeb) return Image.network(caminho, fit: fit, errorBuilder: erro);
    return Image.file(File(caminho), fit: fit, errorBuilder: erro);
  }
}
