import 'dart:typed_data';
import '../repositories/usuario_repository.dart';

class UpdateUsuarioFotoUseCase {
  final UsuarioRepository repository;
  UpdateUsuarioFotoUseCase(this.repository);

  Future<void> call(Uint8List bytes, String extension) {
    return repository.atualizarFoto(bytes, extension);
  }
}