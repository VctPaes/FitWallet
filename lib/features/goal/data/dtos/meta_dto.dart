class MetaDTO {
  final String id;
  final double valor;
  final String periodo;

  MetaDTO({
    required this.id,
    required this.valor,
    required this.periodo,
  });

  factory MetaDTO.fromJson(Map<String, dynamic> json) {
    return MetaDTO(
      id: json['id'] as String,
      valor: json['valor'] as double,
      periodo: json['periodo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valor': valor,
      'periodo': periodo,
    };
  }
}