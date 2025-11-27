import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/usuario_dto.dart';

abstract class UsuarioLocalDataSource {
  Future<UsuarioDTO?> getUsuario();
  Future<void> saveUsuario(UsuarioDTO usuarioDto);
}

class UsuarioLocalDataSourceImpl implements UsuarioLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _key = 'usuario_atual_v2';

  UsuarioLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<UsuarioDTO?> getUsuario() async {
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString != null) {
      return UsuarioDTO.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  @override
  Future<void> saveUsuario(UsuarioDTO usuarioDto) async {
    await sharedPreferences.setString(_key, jsonEncode(usuarioDto.toJson()));
  }
}