import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../dtos/transacao_dto.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransacaoDTO>> getTransactions({String? after});
  Future<void> addTransaction(TransacaoDTO transaction);
  Future<void> updateTransaction(TransacaoDTO transaction);
  Future<void> deleteTransaction(String id);
  Future<void> upsertTransactions(List<TransacaoDTO> transactions);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient client;

  TransactionRemoteDataSourceImpl(this.client);

  @override
  Future<List<TransacaoDTO>> getTransactions({String? after}) async {
    if (kDebugMode) {
      print('TransactionRemoteDataSource: Buscando transações (after: $after)...');
    }

    try {
      var query = client.from('transacoes').select();
      if (after != null) {
        query = query.gt('updated_at', after);
      }
      final response = await query.order('data', ascending: false);

      if (kDebugMode) {
        print('TransactionRemoteDataSource: ${response.length} itens recebidos.');
      }

      final dataList = List<Map<String, dynamic>>.from(response);
      return dataList.map((json) => TransacaoDTO.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print('ERRO TransactionRemoteDataSource: $e');
      throw Exception(
          'Falha ao buscar transações: $e');
    }
  }

  @override
  Future<void> addTransaction(TransacaoDTO transaction) async {
    if (kDebugMode) {
      print('TransactionRemoteDataSource: Adicionando transação "${transaction.titulo}" (ID: ${transaction.id})...');
    }
    
    try {
      await client.from('transacoes').insert(transaction.toSupabaseJson());
      
      if (kDebugMode) {
        print('TransactionRemoteDataSource: Transação adicionada com sucesso.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERRO TransactionRemoteDataSource (add): Falha ao inserir. Erro: $e');
      }
      throw Exception('Erro ao adicionar transação remota: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransacaoDTO transaction) async {
    if (kDebugMode) {
      print('TransactionRemoteDataSource: Atualizando transação ID: ${transaction.id}...');
    }

    try {
      await client
          .from('transacoes')
          .update(transaction.toSupabaseJson())
          .eq('id', transaction.id);

      if (kDebugMode) {
        print('TransactionRemoteDataSource: Transação atualizada com sucesso.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERRO TransactionRemoteDataSource (update): Falha ao atualizar. Erro: $e');
      }
      throw Exception('Erro ao atualizar transação remota: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (kDebugMode) {
      print('TransactionRemoteDataSource: Deletando (soft delete) transação ID: $id...');
    }

    try {
      await client
          .from('transacoes')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);

      if (kDebugMode) {
        print('TransactionRemoteDataSource: Transação marcada como deletada com sucesso.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERRO TransactionRemoteDataSource (delete): Falha ao deletar. Erro: $e');
      }
      throw Exception('Erro ao deletar transação remota: $e');
    }
  }

  @override
  Future<void> upsertTransactions(List<TransacaoDTO> transactions) async {
    if (transactions.isEmpty) return;

    if (kDebugMode) {
      print('TransactionRemoteDataSource: Enviando lote de ${transactions.length} transações...');
    }

    try {
      final List<Map<String, dynamic>> data = transactions
          .map((t) => t.toSupabaseJson())
          .toList();

      await client.from('transacoes').upsert(data);

      if (kDebugMode) {
        print('TransactionRemoteDataSource: Lote enviado com sucesso.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERRO TransactionRemoteDataSource (batch): $e');
      }
      throw Exception('Erro ao enviar lote de transações: $e');
    }
  }
}