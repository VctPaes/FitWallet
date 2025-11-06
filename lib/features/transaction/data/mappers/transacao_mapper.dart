import '../../domain/entities/transacao.dart';
import '../dtos/transacao_dto.dart';

class TransacaoMapper {
  Transacao toEntity(TransacaoDTO dto) {
    return Transacao(
      id: dto.id,
      titulo: dto.titulo,
      valor: dto.valor,
      data: DateTime.parse(dto.data), 
      categoriaId: dto.categoria_id,
    );
  }

  TransacaoDTO toDto(Transacao entity) {
    return TransacaoDTO(
      id: entity.id,
      titulo: entity.titulo,
      valor: entity.valor,
      data: entity.data.toIso8601String(), 
      categoria_id: entity.categoriaId,
    );
  }
}