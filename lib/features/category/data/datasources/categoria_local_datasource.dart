import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/categoria_dto.dart';

abstract class CategoriaLocalDataSource {
  Future<List<CategoriaDTO>> getCategorias();
}

class CategoriaLocalDataSourceImpl implements CategoriaLocalDataSource {
  final SharedPreferences sharedPreferences;
  // Chave para futuras categorias personalizadas
  static const String _key = 'categorias_customizadas'; 

  CategoriaLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<CategoriaDTO>> getCategorias() async {
    // 1. Aqui definimos as categorias padrão do sistema
    // (Isso substitui o switch case da HomePage)
    final defaultCategories = [
      CategoriaDTO(id: 'cat_alimentacao', nome: 'Alimentação', cor_hex: 0xFFFF5252, iconKey: 'fastfood',icone_ponto_de_codigo: 0xe57a),
      CategoriaDTO(id: 'cat_transporte', nome: 'Transporte', cor_hex: 0xFF2196F3, iconKey: 'directions_bus',icone_ponto_de_codigo: 0xe530),
      CategoriaDTO(id: 'cat_lazer', nome: 'Lazer', cor_hex: 0xFFFF9800, iconKey: 'sports_esports',icone_ponto_de_codigo: 0xeb45),
      CategoriaDTO(id: 'cat_moradia', nome: 'Moradia', cor_hex: 0xFF4CAF50, iconKey: 'home',icone_ponto_de_codigo: 0xe88a),
      CategoriaDTO(id: 'cat_outros', nome: 'Outros', cor_hex: 0xFF9E9E9E, iconKey: 'more_horiz',icone_ponto_de_codigo: 0xe5d4),
    ];

    // No futuro, você pode misturar com categorias salvas no SharedPreferences aqui
    return defaultCategories;
  }
}