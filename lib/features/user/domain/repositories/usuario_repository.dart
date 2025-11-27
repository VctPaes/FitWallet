import '../entities/usuario.dart';

abstract class UsuarioRepository {
  Future<Usuario> getUsuario();
  Future<void> salvarUsuario(Usuario usuario);
  Future<void> atualizarFoto(String path);
  Future<void> removerFoto();
}