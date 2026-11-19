import 'package:flutter/widgets.dart' show StringCharacters;

enum Categoria {
  pratoPrincipal('Prato Principal'),
  sobremesa('Sobremesa'),
  aperitivo('Aperitivo'),
  cafeDaManha('Café da Manhã'),
  bebidas('Bebidas');

  const Categoria(this.rotulo);

  final String rotulo;
}

/// Item da lista de ingredientes (Passo 2).
class Ingrediente {
  static const quantidadeMax = 10;
  static const descricaoMax = 80;

  final String quantidade;
  final String descricao;

  const Ingrediente({this.quantidade = '', this.descricao = ''});

  Map<String, dynamic> toJson() => {
    'quantidade': quantidade,
    'descricao': descricao,
  };

  factory Ingrediente.fromJson(Map<String, dynamic> json) => Ingrediente(
    quantidade: json['quantidade'] as String? ?? '',
    descricao: json['descricao'] as String? ?? '',
  );
}

/// Foto ou vídeo anexado a um passo do preparo.
class Midia {
  static const extensoesFoto = ['.jpg', '.jpeg', '.png', '.webp'];
  static const extensoesVideo = ['.mp4', '.mov'];

  /// Caminho do arquivo (na web, URL blob:).
  final String caminho;
  final bool video;

  const Midia({required this.caminho, this.video = false});

  /// Retorna a mídia, ou `null` se o nome do arquivo tiver formato não aceito.
  static Midia? deArquivo({required String caminho, required String nome}) {
    final n = nome.toLowerCase();
    if (extensoesFoto.any(n.endsWith)) return Midia(caminho: caminho);
    if (extensoesVideo.any(n.endsWith)) {
      return Midia(caminho: caminho, video: true);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'caminho': caminho, 'video': video};

  factory Midia.fromJson(Map<String, dynamic> json) => Midia(
    caminho: json['caminho'] as String? ?? '',
    video: json['video'] as bool? ?? false,
  );
}

/// Passo do modo de preparo (Passo 3).
class PassoPreparo {
  static const descricaoMax = 1000;
  static const midiasMax = 5;

  final String descricao;
  final List<Midia> midias;

  const PassoPreparo({this.descricao = '', this.midias = const []});

  Map<String, dynamic> toJson() => {
    'descricao': descricao,
    'midias': [for (final m in midias) m.toJson()],
  };

  factory PassoPreparo.fromJson(Map<String, dynamic> json) => PassoPreparo(
    descricao: json['descricao'] as String? ?? '',
    midias: [
      for (final m in json['midias'] as List? ?? const [])
        Midia.fromJson(m as Map<String, dynamic>),
    ],
  );
}

/// Receita em criação, compartilhada pelos 3 passos do fluxo.
class ReceitaRascunho {
  static const tituloMin = 3;
  static const tituloMax = 60;
  static const historiaMax = 500;
  static const ingredientesMax = 50;
  static const passosMax = 30;

  String? id;
  String? fotoCapa;
  String titulo;
  Categoria categoria;
  String historia;
  List<Ingrediente> ingredientes;
  List<PassoPreparo> passos;
  DateTime? atualizadoEm;

  ReceitaRascunho({
    this.id,
    this.fotoCapa,
    this.titulo = '',
    this.categoria = Categoria.pratoPrincipal,
    this.historia = '',
    List<Ingrediente>? ingredientes,
    List<PassoPreparo>? passos,
    this.atualizadoEm,
  }) : ingredientes = ingredientes ?? [],
       passos = passos ?? [];

  /// Retorna a mensagem de erro do título, ou `null` se válido.
  static String? validarTitulo(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return 'Dê um nome à sua receita.';
    if (texto.characters.length < tituloMin) {
      return 'O título precisa ter pelo menos $tituloMin caracteres.';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fotoCapa': fotoCapa,
    'titulo': titulo,
    'categoria': categoria.name,
    'historia': historia,
    'ingredientes': [for (final i in ingredientes) i.toJson()],
    'passos': [for (final p in passos) p.toJson()],
    'atualizadoEm': atualizadoEm?.toIso8601String(),
  };

  factory ReceitaRascunho.fromJson(Map<String, dynamic> json) =>
      ReceitaRascunho(
        id: json['id'] as String?,
        fotoCapa: json['fotoCapa'] as String?,
        titulo: json['titulo'] as String? ?? '',
        categoria:
            Categoria.values.asNameMap()[json['categoria']] ??
            Categoria.pratoPrincipal,
        historia: json['historia'] as String? ?? '',
        ingredientes: [
          for (final i in json['ingredientes'] as List? ?? const [])
            Ingrediente.fromJson(i as Map<String, dynamic>),
        ],
        passos: [
          for (final p in json['passos'] as List? ?? const [])
            PassoPreparo.fromJson(p as Map<String, dynamic>),
        ],
        atualizadoEm: DateTime.tryParse(json['atualizadoEm'] as String? ?? ''),
      );
}
