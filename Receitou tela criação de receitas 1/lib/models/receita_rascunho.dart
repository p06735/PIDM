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

/// Receita em criação, compartilhada pelos 3 passos do fluxo.
class ReceitaRascunho {
  static const tituloMin = 3;
  static const tituloMax = 60;
  static const historiaMax = 500;
  static const ingredientesMax = 50;

  String? id;
  String? fotoCapa;
  String titulo;
  Categoria categoria;
  String historia;
  List<Ingrediente> ingredientes;
  DateTime? atualizadoEm;

  ReceitaRascunho({
    this.id,
    this.fotoCapa,
    this.titulo = '',
    this.categoria = Categoria.pratoPrincipal,
    this.historia = '',
    List<Ingrediente>? ingredientes,
    this.atualizadoEm,
  }) : ingredientes = ingredientes ?? [];

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
        atualizadoEm: DateTime.tryParse(json['atualizadoEm'] as String? ?? ''),
      );
}
