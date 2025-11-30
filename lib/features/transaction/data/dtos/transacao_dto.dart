class TransacaoDTO {
  final String id;
  final String titulo;
  final double valor;
  final String data;
  final String categoria_id;
  final bool sincronizado;
  final String? deletedAt;

  TransacaoDTO({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.data,
    required this.categoria_id,
    this.sincronizado = true,
    this.deletedAt,
  });

  factory TransacaoDTO.fromJson(Map<String, dynamic> json) {
    return TransacaoDTO(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      valor: (json['valor'] as num).toDouble(),
      data: json['data'] as String,
      categoria_id: json['categoria_id'] as String,
      sincronizado: json['sincronizado'] ?? true,
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'data': data,
      'categoria_id': categoria_id,
      'sincronizado': sincronizado,
      'deleted_at': deletedAt,
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'data': data,
      'categoria_id': categoria_id,
      'deleted_at': deletedAt,
    };
  }

  TransacaoDTO copyWith({bool? sincronizado, String? deletedAt}) {
    return TransacaoDTO(
      id: id,
      titulo: titulo,
      valor: valor,
      data: data,
      categoria_id: categoria_id,
      sincronizado: sincronizado ?? this.sincronizado,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}