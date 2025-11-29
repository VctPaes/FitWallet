import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/transacao_dto.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransacaoDTO>> getTransactions();
  Future<void> addTransaction(TransacaoDTO transaction);
  Future<void> updateTransaction(TransacaoDTO transaction); // Método que faltava
  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient client;

  TransactionRemoteDataSourceImpl(this.client);

  @override
  Future<List<TransacaoDTO>> getTransactions() async {
    final response = await client
        .from('transacoes')
        .select()
        .order('data', ascending: false);

    final dataList = List<Map<String, dynamic>>.from(response);
    return dataList.map((json) => TransacaoDTO.fromJson(json)).toList();
  }

  @override
  Future<void> addTransaction(TransacaoDTO transaction) async {
    await client.from('transacoes').insert(transaction.toJson());
  }

  @override
  Future<void> updateTransaction(TransacaoDTO transaction) async {
    // Atualiza no Supabase
    await client
        .from('transacoes')
        .update(transaction.toJson())
        .eq('id', transaction.id);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await client.from('transacoes').delete().eq('id', id);
  }
}