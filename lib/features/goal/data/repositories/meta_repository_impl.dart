import '../../domain/entities/meta.dart';
import '../../domain/repositories/meta_repository.dart';
import '../datasources/meta_local_datasource.dart';
import '../dtos/meta_dto.dart';
import '../mappers/meta_mapper.dart';

class MetaRepositoryImpl implements MetaRepository {
  final MetaLocalDataSource dataSource;
  final MetaMapper mapper;

  MetaRepositoryImpl(this.dataSource, this.mapper);

  @override
  Future<Meta> getMeta() async {
    final dto = await dataSource.getMeta();
    if (dto != null) {
      return mapper.toEntity(dto);
    }
    // Retorna um valor padrão se não existir
    return Meta(id: 'meta_semanal', valor: 150.0, periodo: 'semanal');
  }

  @override
  Future<void> updateMeta(double novoValor) async {
    // Mantém ID fixo por enquanto, pois é meta única
    final novaMetaDto = MetaDTO(
      id: 'meta_semanal', 
      valor: novoValor, 
      periodo: 'semanal'
    );
    await dataSource.saveMeta(novaMetaDto);
  }
}