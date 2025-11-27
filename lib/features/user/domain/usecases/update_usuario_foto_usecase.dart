import '../repositories/usuario_repository.dart';

class UpdateUsuarioFotoUseCase {
  final UsuarioRepository repository;
  UpdateUsuarioFotoUseCase(this.repository);

  Future<void> call(String path) {
    return repository.atualizarFoto(path);
  }
}