import 'package:flutter/material.dart';
import '../../domain/entities/transacao.dart';
// Note que agora dependemos diretamente do Repositório para os métodos novos,
// ou precisaríamos criar novos UseCases (GetTransactionsUseCase, SyncTransactionsUseCase).
// Para simplificar e manter o padrão Clean, vamos assumir que o GetTransactionsUseCase
// foi atualizado ou que chamamos o método apropriado.
import '../../domain/repositories/transaction_repository.dart'; 
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';

class TransactionProvider extends ChangeNotifier {
  // Vamos injetar o Repositório diretamente para acessar o loadFromCache/sync
  // (Ou idealmente, criar UseCases específicos para isso)
  final TransactionRepository _repository;
  
  final AddTransactionUseCase _addTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  List<Transacao> _transacoes = [];
  bool _isLoading = false;
  String? _error;

  List<Transacao> get transacoes => _transacoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TransactionProvider({
    required TransactionRepository repository,
    required AddTransactionUseCase addTransactionUseCase,
    required UpdateTransactionUseCase updateTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
  })  : _repository = repository,
        _addTransactionUseCase = addTransactionUseCase,
        _updateTransactionUseCase = updateTransactionUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase;

  // --- Nova Lógica de Carregamento ---

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. CARGA RÁPIDA (Cache Local)
      _transacoes = await _repository.loadFromCache();
      _isLoading = false; 
      notifyListeners(); // Mostra dados locais imediatamente

      // 2. SINCRONIZAÇÃO (Fundo)
      // O usuário já vê os dados, mas atualizamos se houver novidade
      final novosItens = await _repository.syncFromServer();
      
      if (novosItens > 0) {
        _transacoes = await _repository.listAll();
        notifyListeners();
      }
      
    } catch (e) {
      _error = 'Falha ao carregar transações';
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CRUD Mantido ---

  Future<void> addTransaction(Transacao transacao) async {
    try {
      await _addTransactionUseCase(transacao);
      await loadTransactions();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(Transacao transacao) async {
    await _updateTransactionUseCase(transacao);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _deleteTransactionUseCase(id);
    await loadTransactions();
  }
}