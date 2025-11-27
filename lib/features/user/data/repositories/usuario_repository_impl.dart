import '../../domain/entities/usuario.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_local_datasource.dart';
import '../dtos/usuario_dto.dart';
import '../mappers/usuario_mapper.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioLocalDataSource dataSource;
  final UsuarioMapper mapper;

  UsuarioRepositoryImpl(this.dataSource, this.mapper);

  @override
  Future<Usuario> getUsuario() async {
    final dto = await dataSource.getUsuario();
    if (dto != null) {
      return mapper.toEntity(dto);
    }
    // Retorna um usuário padrão se não existir (Placeholder)
    return Usuario(
      id: 'user_default',
      nome: 'Estudante',
      email: Email('estudante@fitwallet.com'),
      fotoPath: null,
    );
  }

  @override
  Future<void> salvarUsuario(Usuario usuario) async {
    await dataSource.saveUsuario(mapper.toDto(usuario));
  }

  @override
  Future<void> atualizarFoto(String path) async {
    final usuarioAtual = await getUsuario();
    // Cria um novo objeto com a foto atualizada (Imutabilidade)
    final novoUsuario = Usuario(
      id: usuarioAtual.id,
      nome: usuarioAtual.nome,
      email: usuarioAtual.email,
      fotoPath: path,
    );
    await salvarUsuario(novoUsuario);
  }

  @override
  Future<void> atualizarNome(String novoNome) async {
    final usuarioAtual = await getUsuario();
    
    // Cria uma cópia do usuário com o novo nome (Imutabilidade)
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
      fotoPath: null, // Remove a foto
    );
    await salvarUsuario(novoUsuario);
  }
}