import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/transacao_dto.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransacaoDTO>> getTransactions();
  Future<void> saveTransactions(List<TransacaoDTO> transactions);
  Future<String?> getLastSyncTime();
  Future<void> saveLastSyncTime(String isoTime);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _keyData = 'transacoes_v2';
  static const String _keySync = 'last_sync_timestamp';

  TransactionLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<TransacaoDTO>> getTransactions() async {
    final jsonString = sharedPreferences.getString(_keyData);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((e) => TransacaoDTO.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveTransactions(List<TransacaoDTO> dtos) async {
    final String jsonString = jsonEncode(dtos.map((dto) => dto.toJson()).toList());
    await sharedPreferences.setString(_keyData, jsonString);
  }

  @override
  Future<String?> getLastSyncTime() async {
    return sharedPreferences.getString(_keySync);
  }

  @override
  Future<void> saveLastSyncTime(String isoTime) async {
    await sharedPreferences.setString(_keySync, isoTime);
  }
}