import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/rascunho_repository.dart';
import '../../models/receita_rascunho.dart';
import '../../theme/app_theme.dart';
import 'nova_receita_fluxo.dart';
import 'nova_receita_ingredientes_screen.dart';
import 'widgets/componentes_fluxo.dart';
import 'widgets/indicador_passos.dart';

typedef SelecionarImagem = Future<XFile?> Function(ImageSource origem);

/// Nova Receita · Passo 1: Informações Básicas.
/// Spec: specs/nova_receita_passo1_informacoes.md
class NovaReceitaInformacoesScreen extends StatefulWidget {
  static const tamanhoMaxFoto = 10 * 1024 * 1024;
  static const extensoesFoto = ['.jpg', '.jpeg', '.png'];

  final RascunhoRepository repository;
  final SelecionarImagem? selecionarImagem;

  NovaReceitaInformacoesScreen({
    super.key,
    RascunhoRepository? repository,
    this.selecionarImagem,
  }) : repository = repository ?? RascunhoRepository();

  @override
  State<NovaReceitaInformacoesScreen> createState() =>
      _NovaReceitaInformacoesScreenState();
}

class _NovaReceitaInformacoesScreenState
    extends State<NovaReceitaInformacoesScreen> {
  late final _fluxo = NovaReceitaFluxo(repository: widget.repository);
  final _tituloController = TextEditingController();
  final _historiaController = TextEditingController();
  final _tituloKey = GlobalKey();

  String? _erroTitulo;
  bool _tentouContinuar = false;

  ReceitaRascunho get _rascunho => _fluxo.rascunho;

  @override
  void dispose() {
    _tituloController.dispose();
    _historiaController.dispose();
    super.dispose();
  }

  Future<void> _salvarRascunho() async {
    await _fluxo.salvar();
    if (mounted) avisar(context, 'Rascunho salvo');
  }

  Future<void> _fechar() async {
    final navigator = Navigator.of(context);
    if (await confirmarFechamento(context, _fluxo)) navigator.pop();
  }

  Future<void> _escolherFoto() async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origem == null) return;

    final selecionar =
        widget.selecionarImagem ??
        (origem) => ImagePicker().pickImage(source: origem);
    final arquivo = await selecionar(origem);
    if (arquivo == null || !mounted) return;

    final nome = arquivo.name.toLowerCase();
    final formatoValido = NovaReceitaInformacoesScreen.extensoesFoto.any(
      (extensao) => nome.endsWith(extensao),
    );
    final arquivoValido =
        formatoValido &&
        await arquivo.length() <= NovaReceitaInformacoesScreen.tamanhoMaxFoto;
    if (!mounted) return;
    if (!arquivoValido) {
      avisar(context, 'Use uma imagem JPG ou PNG de até 10 MB.');
      return;
    }
    setState(() => _rascunho.fotoCapa = arquivo.path);
  }

  Future<void> _continuar() async {
    final erro = ReceitaRascunho.validarTitulo(_tituloController.text);
    setState(() {
      _tentouContinuar = true;
      _erroTitulo = erro;
    });
    if (erro != null) {
      Scrollable.ensureVisible(
        _tituloKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        alignment: 0.2,
      );
      return;
    }
    final navigator = Navigator.of(context);
    // O passo seguinte retorna `true` quando o usuário fecha o fluxo pelo X.
    final fecharFluxo = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => NovaReceitaIngredientesScreen(fluxo: _fluxo),
      ),
    );
    if (fecharFluxo == true) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _fechar();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: _fechar,
          ),
          title: const Text('Nova Receita'),
        ),
        body: Column(
          children: [
            const IndicadorPassos(passoAtual: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CabecalhoPasso(
                      titulo: 'Informações Básicas',
                      subtitulo:
                          'Comece dando um rosto e um nome para a sua criação '
                          'culinária.',
                    ),
                    const SizedBox(height: 24),
                    _FotoCapa(
                      caminho: _rascunho.fotoCapa,
                      onTap: _escolherFoto,
                      onRemover: () =>
                          setState(() => _rascunho.fotoCapa = null),
                    ),
                    const SizedBox(height: 24),
                    const _Rotulo('Título da Receita'),
                    TextField(
                      key: _tituloKey,
                      controller: _tituloController,
                      maxLength: ReceitaRascunho.tituloMax,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onChanged: (valor) => setState(() {
                        _rascunho.titulo = valor.trim();
                        if (_tentouContinuar) {
                          _erroTitulo = ReceitaRascunho.validarTitulo(valor);
                        }
                      }),
                      decoration: InputDecoration(
                        hintText: 'Ex: Risoto de Cogumelos Selvagens',
                        counterText: '',
                        errorText: _erroTitulo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _Rotulo('Categoria Principal'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final categoria in Categoria.values)
                          _ChipCategoria(
                            categoria: categoria,
                            selecionado: categoria == _rascunho.categoria,
                            onTap: () =>
                                setState(() => _rascunho.categoria = categoria),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _Rotulo('História ou Descrição'),
                    TextField(
                      controller: _historiaController,
                      // Ao focar, rola o campo inteiro (4 linhas + contador) para
                      // cima do rodapé, não só a linha do cursor.
                      scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
                      maxLength: ReceitaRascunho.historiaMax,
                      minLines: 4,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (valor) =>
                          setState(() => _rascunho.historia = valor),
                      decoration: const InputDecoration(
                        hintText:
                            'O que torna esta receita especial? Conte a '
                            'inspiração por trás dela...',
                        hintMaxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: RodapeFluxo(
          rotuloSecundario: 'Salvar Rascunho',
          onSecundario: _salvarRascunho,
          onContinuar: _continuar,
          teclado: MediaQuery.viewInsetsOf(context).bottom,
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;

  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
      ),
    );
  }
}

class _FotoCapa extends StatelessWidget {
  final String? caminho;
  final VoidCallback onTap;
  final VoidCallback onRemover;

  const _FotoCapa({
    required this.caminho,
    required this.onTap,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(12);
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Material(
            color: AppColors.superficie,
            borderRadius: raio,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: caminho != null
                  // Na web, o caminho do XFile é uma URL blob:.
                  ? kIsWeb
                        ? Image.network(caminho!, fit: BoxFit.cover)
                        : Image.file(File(caminho!), fit: BoxFit.cover)
                  : CustomPaint(
                      painter: _BordaTracejada(raio: 12),
                      // Com fonte grande o conteúdo é reduzido para caber na
                      // área 4:3 em vez de estourar a altura.
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 32,
                                color: AppColors.terracota,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Adicionar Foto de Capa',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.texto,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Formatos recomendados: JPG, PNG (Paisagem)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          if (caminho != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                tooltip: 'Remover foto',
                icon: const Icon(Icons.close, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: onRemover,
              ),
            ),
        ],
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  final double raio;

  _BordaTracejada({required this.raio});

  @override
  void paint(Canvas canvas, Size size) {
    const traco = 6.0, espaco = 4.0;
    final paint = Paint()
      ..color = AppColors.borda
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final contorno = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          Radius.circular(raio),
        ),
      );
    for (final metrica in contorno.computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += traco + espaco) {
        canvas.drawPath(metrica.extractPath(d, d + traco), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejada oldDelegate) => oldDelegate.raio != raio;
}

class _ChipCategoria extends StatelessWidget {
  final Categoria categoria;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipCategoria({
    required this.categoria,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(categoria.rotulo),
      selected: selecionado,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.terracota,
      backgroundColor: AppColors.superficie,
      side: BorderSide(
        color: selecionado ? AppColors.terracota : AppColors.borda,
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selecionado ? Colors.white : AppColors.texto,
      ),
    );
  }
}
