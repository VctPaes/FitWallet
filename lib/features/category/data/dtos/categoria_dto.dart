class CategoriaDTO {
  final String id;
  final String nome;
  final int icone_ponto_de_codigo;
  final int cor_hex;
  final String iconKey;

  CategoriaDTO({
    required this.id,
    required this.nome,
    required this.icone_ponto_de_codigo,
    required this.cor_hex,
    required this.iconKey,
  });

  factory CategoriaDTO.fromJson(Map<String, dynamic> json) {
    return CategoriaDTO(
      id: json['id'] as String,
      nome: json['nome'] as String,
      icone_ponto_de_codigo: json['icone_ponto_de_codigo'] as int,
      cor_hex: json['cor_hex'] as int,
      iconKey: json['iconKey'] ?? 'category',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'icone_ponto_de_codigo': icone_ponto_de_codigo,
      'cor_hex': cor_hex,
      'iconKey': iconKey,
    };
  }
}