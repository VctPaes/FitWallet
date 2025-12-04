import 'dart:typed_data';
import '../entities/usuario.dart';

abstract class UsuarioRepository {
  Future<Usuario> getUsuario();
  Future<void> salvarUsuario(Usuario usuario);
  Future<void> removerFoto();
  Future<void> atualizarNome(String novoNome);
  Future<void> atualizarFoto(Uint8List imageBytes, String extension);
}