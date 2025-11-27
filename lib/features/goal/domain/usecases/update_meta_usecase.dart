import '../repositories/meta_repository.dart';

class UpdateMetaUseCase {
  final MetaRepository repository;
  UpdateMetaUseCase(this.repository);

  Future<void> call(double novoValor) {
    return repository.updateMeta(novoValor);
  }
}