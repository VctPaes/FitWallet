import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transaction_repository.dart'; 
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';

class TransactionProvider extends ChangeNotifier {
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

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transacoes = await _repository.loadFromCache();
      _isLoading = false; 
      notifyListeners(); 

      if (_transacoes.isEmpty) {
        if (kDebugMode) print('Cache vazio detectado. Iniciando sync automático...');
        final novosItens = await _repository.syncFromServer();
        if (novosItens > 0) {
          _transacoes = await _repository.listAll();
          notifyListeners();
        }
      }
      
    } catch (e) {
      _error = 'Falha ao carregar transações';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTransactions() async {
    try {
      // Força a sincronização independente do estado da lista
      await _repository.syncFromServer();
      // Recarrega a lista atualizada
      _transacoes = await _repository.listAll();
      notifyListeners();
    } catch (e) {
      // Opcional: Tratar erro silencioso ou notificar UI via SnackBar na View
      if (kDebugMode) print('Erro no refresh manual: $e');
    }
  }

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