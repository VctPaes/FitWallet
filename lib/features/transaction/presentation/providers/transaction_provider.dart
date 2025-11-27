import 'package:flutter/material.dart';
import '../../domain/entities/transacao.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';

class TransactionProvider extends ChangeNotifier {
  // Dependências (UseCases)
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  // Estado
  List<Transacao> _transacoes = [];
  bool _isLoading = false;
  String? _error;

  // Getters para a UI
  List<Transacao> get transacoes => _transacoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Construtor com Injeção de Dependência
  TransactionProvider({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
    required UpdateTransactionUseCase updateTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase,
        _addTransactionUseCase = addTransactionUseCase,
        _updateTransactionUseCase = updateTransactionUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase;

  // --- Métodos Públicos ---

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transacoes = await _getTransactionsUseCase();
    } catch (e) {
      _error = 'Falha ao carregar transações';
      // Em um app real, use um Logger
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transacao transacao) async {
    try {
      await _addTransactionUseCase(transacao);
      await loadTransactions(); // Recarrega a lista atualizada
    } catch (e) {
      _error = 'Erro ao adicionar transação';
      notifyListeners();
      rethrow; // Permite que a UI trate o erro se quiser (ex: SnackBar)
    }
  }

  Future<void> updateTransaction(Transacao transacao) async {
    try {
      await _updateTransactionUseCase(transacao);
      await loadTransactions();
    } catch (e) {
      _error = 'Erro ao atualizar transação';
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _deleteTransactionUseCase(id);
      await loadTransactions();
    } catch (e) {
      _error = 'Erro ao remover transação';
      notifyListeners();
    }
  }
}