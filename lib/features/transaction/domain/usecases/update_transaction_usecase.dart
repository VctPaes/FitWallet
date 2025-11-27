import '../entities/transacao.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<void> call(Transacao transacao) {
    return repository.updateTransaction(transacao);
  }
}