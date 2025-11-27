import '../entities/categoria.dart';

abstract class CategoriaRepository {
  Future<List<Categoria>> getCategorias();
  // No futuro pode adicionar: createCategoria, deleteCategoria, etc.
}