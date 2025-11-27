import '../../domain/entities/categoria.dart';
import '../dtos/categoria_dto.dart';

class CategoriaMapper {

  Categoria toEntity(CategoriaDTO dto) {
    return Categoria(
      id: dto.id,
      nome: dto.nome,
      iconePontoDeCodigo: dto.icone_ponto_de_codigo,
      corHex: dto.cor_hex,
      iconKey: dto.iconKey,
    );
  }

  CategoriaDTO toDto(Categoria entity) {
    return CategoriaDTO(
      id: entity.id,
      nome: entity.nome,
      icone_ponto_de_codigo: entity.iconePontoDeCodigo,
      cor_hex: entity.corHex,
      iconKey: entity.iconKey,
    );
  }
}