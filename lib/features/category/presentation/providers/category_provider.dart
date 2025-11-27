import 'package:flutter/material.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/usecases/get_categorias_usecase.dart';

class CategoryProvider extends ChangeNotifier {
  final GetCategoriasUseCase getCategoriasUseCase;

  List<Categoria> _categorias = [];
  bool _isLoading = false;

  CategoryProvider({required this.getCategoriasUseCase});

  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;

  Future<void> loadCategorias() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categorias = await getCategoriasUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Helpers de UI ---
  // Este método substitui o switch gigante da HomePage
  
  Categoria? getCategoriaById(String id) {
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mapa estático para converter String -> IconData
  // A UI chama isso passando o category.iconKey
  static IconData getIconFromKey(String key) {
    switch (key) {
      case 'fastfood': return Icons.fastfood;
      case 'directions_bus': return Icons.directions_bus;
      case 'sports_esports': return Icons.sports_esports;
      case 'home': return Icons.home;
      case 'more_horiz': return Icons.more_horiz;
      // Adicione mais ícones conforme necessário
      default: return Icons.category;
    }
  }
}