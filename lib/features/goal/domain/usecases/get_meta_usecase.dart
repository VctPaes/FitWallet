import '../entities/meta.dart';
import '../repositories/meta_repository.dart';

class GetMetaUseCase {
  final MetaRepository repository;
  GetMetaUseCase(this.repository);

  Future<Meta> call() {
    return repository.getMeta();
  }
}