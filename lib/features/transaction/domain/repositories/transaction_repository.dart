import '../entities/transacao.dart';

abstract class TransactionRepository {
  // Busca todas as transações
  Future<List<Transacao>> getTransactions();
  
  // Adiciona uma nova transação
  Future<void> addTransaction(Transacao transacao);
  
  // Atualiza uma transação existente
  Future<void> updateTransaction(Transacao transacao);
  
  // Remove uma transação pelo ID
  Future<void> deleteTransaction(String id);
}