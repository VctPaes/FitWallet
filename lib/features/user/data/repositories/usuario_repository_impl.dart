import 'package:flutter/foundation.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_local_datasource.dart';
import '../datasources/usuario_remote_datasource.dart';
import '../dtos/usuario_dto.dart';
import '../mappers/usuario_mapper.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioLocalDataSource localDataSource;
  final UsuarioRemoteDataSource remoteDataSource;
  final UsuarioMapper mapper;

  UsuarioRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,
    this.mapper,
  );

  @override
  Future<Usuario> getUsuario() async {
    try {
      final remoteDto = await remoteDataSource.getProfile();
      if (remoteDto != null) {
        if (kDebugMode) print('UsuarioRepository: Perfil atualizado baixado do servidor.');
        
        await localDataSource.saveUsuario(remoteDto);
        return mapper.toEntity(remoteDto);
      }
    } catch (e) {
      if (kDebugMode) print('UsuarioRepository: Sem internet ou erro remoto. Usando cache local. Erro: $e');
    }

    try {
      final localDto = await localDataSource.getUsuario();
      if (localDto != null) {
        return mapper.toEntity(localDto);
      }
    } catch (e) {
      if (kDebugMode) print('UsuarioRepository: Erro ao ler local: $e');
    }

    return Usuario(
      id: 'user_default',
      nome: 'Estudante',
      email: Email('estudante@fitwallet.com'),
      fotoPath: null,
    );
  }

  @override
  Future<void> salvarUsuario(Usuario usuario) async {
    final dto = mapper.toDto(usuario);

    await localDataSource.saveUsuario(dto);
    if (kDebugMode) print('UsuarioRepository: Perfil salvo localmente.');

    try {
      await remoteDataSource.updateProfile(dto);
      if (kDebugMode) print('UsuarioRepository: Perfil sincronizado com sucesso.');
    } catch (e) {
      if (kDebugMode) print('UsuarioRepository: Falha no sync remoto (será tentado depois): $e');
    }
  }

  @override
  Future<void> atualizarFoto(Uint8List imageBytes, String extension) async {
    final usuarioAtual = await getUsuario();
    
    final remoteUrl = await remoteDataSource.uploadAvatar(usuarioAtual.id, imageBytes, extension);

    final novoUsuario = Usuario(
      id: usuarioAtual.id,
      nome: usuarioAtual.nome,
      email: usuarioAtual.email,
      fotoPath: remoteUrl, 
    );

    await salvarUsuario(novoUsuario);
  }

  @override
  Future<void> atualizarNome(String novoNome) async {
    final usuarioAtual = await getUsuario();
    final novoUsuario = Usuario(
      id: usuarioAtual.id,
      nome: novoNome,
      email: usuarioAtual.email,
      fotoPath: usuarioAtual.fotoPath,
    );
    await salvarUsuario(novoUsuario);
  }

  @override
  Future<void> removerFoto() async {
    final usuarioAtual = await getUsuario();
    
    final novoUsuario = Usuario(
      id: usuarioAtual.id,
      nome: usuarioAtual.nome,
      email: usuarioAtual.email,
      fotoPath: null,
    );
    await salvarUsuario(novoUsuario);
  }
}