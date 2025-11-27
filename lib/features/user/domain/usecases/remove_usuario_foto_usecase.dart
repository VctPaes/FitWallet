import '../repositories/usuario_repository.dart';

class RemoveUsuarioFotoUseCase {
  final UsuarioRepository repository;
  RemoveUsuarioFotoUseCase(this.repository);

  Future<void> call() {
    return repository.removerFoto();
  }
}