import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../datasources/categoria_local_datasource.dart';
import '../mappers/categoria_mapper.dart';

class CategoriaRepositoryImpl implements CategoriaRepository {
  final CategoriaLocalDataSource dataSource;
  final CategoriaMapper mapper;

  CategoriaRepositoryImpl(this.dataSource, this.mapper);

  @override
  Future<List<Categoria>> getCategorias() async {
    final dtos = await dataSource.getCategorias();
    return dtos.map((dto) => mapper.toEntity(dto)).toList();
  }
}