import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/meta_dto.dart';

abstract class MetaLocalDataSource {
  Future<MetaDTO?> getMeta();
  Future<void> saveMeta(MetaDTO metaDto);
}

class MetaLocalDataSourceImpl implements MetaLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _key = 'meta_atual';

  MetaLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<MetaDTO?> getMeta() async {
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString != null) {
      return MetaDTO.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  @override
  Future<void> saveMeta(MetaDTO metaDto) async {
    await sharedPreferences.setString(_key, jsonEncode(metaDto.toJson()));
  }
}