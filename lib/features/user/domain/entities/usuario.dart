import '../value_objects/email.dart';

class Usuario {
  final String id;
  final String nome;
  final Email email;
  final String? fotoPath; 

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.fotoPath,
  });

  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome, email: $email, fotoPath: $fotoPath)';
  }
}