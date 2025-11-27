import '../entities/usuario.dart';
import '../repositories/usuario_repository.dart';

class GetUsuarioUseCase {
  final UsuarioRepository repository;
  GetUsuarioUseCase(this.repository);

  Future<Usuario> call() {
    return repository.getUsuario();
  }
}