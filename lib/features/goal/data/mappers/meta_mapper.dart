import '../../domain/entities/meta.dart';
import '../dtos/meta_dto.dart';

class MetaMapper {
  Meta toEntity(MetaDTO dto) {
    return Meta(
      id: dto.id,
      valor: dto.valor,
      periodo: dto.periodo,
    );
  }

  MetaDTO toDto(Meta entity) {
    return MetaDTO(
      id: entity.id,
      valor: entity.valor,
      periodo: entity.periodo,
    );
  }
}