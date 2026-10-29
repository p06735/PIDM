enum Categoria {
  pratoPrincipal('Prato Principal'),
  sobremesa('Sobremesa'),
  aperitivo('Aperitivo'),
  cafeDaManha('Café da Manhã'),
  bebidas('Bebidas');

  const Categoria(this.rotulo);

  final String rotulo;
}

/// Receita em criação, compartilhada pelos 3 passos do fluxo.
class ReceitaRascunho {
  static const tituloMin = 3;
  static const tituloMax = 60;
  static const historiaMax = 500;

  String? id;
  String? fotoCapa;
  String titulo;
  Categoria categoria;
  String historia;
  DateTime? atualizadoEm;

  ReceitaRascunho({
    this.id,
    this.fotoCapa,
    this.titulo = '',
    this.categoria = Categoria.pratoPrincipal,
    this.historia = '',
    this.atualizadoEm,
  });

  /// Retorna a mensagem de erro do título, ou `null` se válido.
  static String? validarTitulo(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return 'Dê um nome à sua receita.';
    if (texto.length < tituloMin) {
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
        'atualizadoEm': atualizadoEm?.toIso8601String(),
      };

  factory ReceitaRascunho.fromJson(Map<String, dynamic> json) =>
      ReceitaRascunho(
        id: json['id'] as String?,
        fotoCapa: json['fotoCapa'] as String?,
        titulo: json['titulo'] as String? ?? '',
        categoria: Categoria.values.asNameMap()[json['categoria']] ??
            Categoria.pratoPrincipal,
        historia: json['historia'] as String? ?? '',
        atualizadoEm: DateTime.tryParse(json['atualizadoEm'] as String? ?? ''),
      );
}
