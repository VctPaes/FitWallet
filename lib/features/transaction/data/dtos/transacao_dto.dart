class TransacaoDTO {
  final String id;
  final String titulo;
  final double valor;
  final String data; // String ISO 8601
  final String categoria_id;

  TransacaoDTO({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.data,
    required this.categoria_id,
  });

  factory TransacaoDTO.fromJson(Map<String, dynamic> json) {
    return TransacaoDTO(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      valor: json['valor'] as double,
      data: json['data'] as String,
      categoria_id: json['categoria_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'data': data,
      'categoria_id': categoria_id,
    };
  }
}