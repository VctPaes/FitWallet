import 'dart:math'; // Para simular delay aleatório
import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../mappers/transacao_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource dataSource;
  final TransacaoMapper mapper;

  TransactionRepositoryImpl(this.dataSource, this.mapper);

  // --- Implementação dos Novos Métodos ---

  @override
  Future<List<Transacao>> loadFromCache() async {
    // Busca direto do SharedPreferences
    final dtos = await dataSource.getTransactions();
    return dtos.map((dto) => mapper.toEntity(dto)).toList();
  }

  @override
  Future<int> syncFromServer() async {
    // SIMULAÇÃO DE API: Finge que foi ao servidor buscar dados
    await Future.delayed(const Duration(seconds: 2)); 
    
    // Aqui você implementaria a lógica real:
    // 1. GET /transactions?last_sync=...
    // 2. Comparar com local
    // 3. Salvar novos itens no dataSource
    
    // Por enquanto, retornamos 0 indicando que não há dados novos do servidor
    return 0; 
  }

  @override
  Future<List<Transacao>> listAll() async {
    // No nosso caso, é igual ao loadFromCache
    return loadFromCache();
  }

  // --- Implementação dos Métodos Originais (CRUD) ---

  @override
  Future<void> addTransaction(Transacao transacao) async {
    final dtos = await dataSource.getTransactions();
    // Adiciona no início da lista
    dtos.insert(0, mapper.toDto(transacao));
    await dataSource.saveTransactions(dtos);
  }

  @override
  Future<void> updateTransaction(Transacao transacao) async {
    final dtos = await dataSource.getTransactions();
    final index = dtos.indexWhere((t) => t.id == transacao.id);
    if (index != -1) {
      dtos[index] = mapper.toDto(transacao);
      await dataSource.saveTransactions(dtos);
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final dtos = await dataSource.getTransactions();
    dtos.removeWhere((t) => t.id == id);
    await dataSource.saveTransactions(dtos);
  }
}