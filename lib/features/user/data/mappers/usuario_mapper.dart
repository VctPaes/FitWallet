import '../../domain/entities/usuario.dart';
import '../../domain/value_objects/email.dart';
import '../dtos/usuario_dto.dart';

/// Mapper para conversão bidirecional entre Usuario (Entidade) e UsuarioDTO.
class UsuarioMapper {
  /// Converte um DTO (dados crus) para uma Entidade (domínio).
  Usuario toEntity(UsuarioDTO dto) {
    try {
      return Usuario(
        id: dto.id,
        nome: dto.nome_completo,
        email: Email(dto.email), 
        fotoPath: dto.foto_caminho,
      );
    } catch (e) {
      print('Erro ao mapear UsuarioDTO para Entidade: $e');
      throw Exception('Dados do usuário inválidos no DTO: $e');
    }
  }

  UsuarioDTO toDto(Usuario entity) {
    return UsuarioDTO(
      id: entity.id,
      nome_completo: entity.nome,
      email: entity.email.value,
      foto_caminho: entity.fotoPath,
    );
  }
}