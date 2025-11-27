import '../entities/transacao.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<void> call(Transacao transacao) {
    return repository.addTransaction(transacao);
  }
}