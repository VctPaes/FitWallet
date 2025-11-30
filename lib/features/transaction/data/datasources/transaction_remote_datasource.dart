import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/transacao_dto.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransacaoDTO>> getTransactions({String? after}); 
  Future<void> addTransaction(TransacaoDTO transaction);
  Future<void> updateTransaction(TransacaoDTO transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient client;

  TransactionRemoteDataSourceImpl(this.client);

  @override
  Future<List<TransacaoDTO>> getTransactions({String? after}) async {
    var query = client.from('transacoes').select();
    
    if (after != null) {
      query = query.gt('updated_at', after);
    }
    
    final response = await query.order('data', ascending: false);
    final dataList = List<Map<String, dynamic>>.from(response);
    return dataList.map((json) => TransacaoDTO.fromJson(json)).toList();
  }

  @override
  Future<void> addTransaction(TransacaoDTO transaction) async {
    await client.from('transacoes').insert(transaction.toSupabaseJson());
  }

  @override
  Future<void> updateTransaction(TransacaoDTO transaction) async {
    await client
        .from('transacoes')
        .update(transaction.toSupabaseJson())
        .eq('id', transaction.id);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await client
        .from('transacoes')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
}