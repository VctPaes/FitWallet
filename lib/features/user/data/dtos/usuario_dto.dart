class UsuarioDTO {
  final String id;
  final String nome_completo; 
  final String email;
  final String? foto_caminho; 

  UsuarioDTO({
    required this.id,
    required this.nome_completo,
    required this.email,
    this.foto_caminho,
  });

  factory UsuarioDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioDTO(
      id: json['id'] as String,
      nome_completo: json['nome_completo'] as String,
      email: json['email'] as String,
      foto_caminho: json['foto_caminho'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nome_completo,
      'email': email,
      'foto_caminho': foto_caminho,
    };
  }
}