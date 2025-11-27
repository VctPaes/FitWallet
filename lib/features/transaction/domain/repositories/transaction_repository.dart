import '../entities/transacao.dart';

abstract class TransactionRepository {
  // --- Novos Métodos (Leitura & Sync) ---
  
  /// Carrega dados locais imediatamente.
  Future<List<Transacao>> loadFromCache();

  /// Simula uma sincronização com servidor (retorna qtde de novos itens).
  Future<int> syncFromServer();

  /// Retorna a lista consolidada.
  Future<List<Transacao>> listAll();

  // --- Métodos Originais (CRUD) ---
  // Mantidos para não quebrar a funcionalidade de adicionar gastos
  
  Future<void> addTransaction(Transacao transacao);
  Future<void> updateTransaction(Transacao transacao);
  Future<void> deleteTransaction(String id);
}