import '../repositories/usuario_repository.dart';

class UpdateUsuarioNomeUseCase {
  final UsuarioRepository repository;

  UpdateUsuarioNomeUseCase(this.repository);

  Future<void> call(String novoNome) {
    if (novoNome.trim().isEmpty) {
      throw ArgumentError("O nome não pode ser vazio.");
    }
    return repository.atualizarNome(novoNome.trim());
  }
}