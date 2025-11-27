import '../entities/meta.dart';

abstract class MetaRepository {
  Future<Meta> getMeta();
  Future<void> updateMeta(double novoValor);
}