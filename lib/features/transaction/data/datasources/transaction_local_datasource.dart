import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/transacao_dto.dart';

// Contrato do DataSource
abstract class TransactionLocalDataSource {
  Future<List<TransacaoDTO>> getTransactions();
  Future<void> saveTransactions(List<TransacaoDTO> transactions);
}

// Implementação usando SharedPreferences
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final SharedPreferences sharedPreferences;
  // Usamos uma chave constante para evitar erros de digitação
  static const String _key = 'transacoes_v2'; 

  TransactionLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<TransacaoDTO>> getTransactions() async {
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((e) => TransacaoDTO.fromJson(e)).toList();
      } catch (e) {
        // Em um app real, você poderia logar esse erro
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveTransactions(List<TransacaoDTO> dtos) async {
    final String jsonString = jsonEncode(dtos.map((dto) => dto.toJson()).toList());
    await sharedPreferences.setString(_key, jsonString);
  }
}