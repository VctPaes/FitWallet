import '../entities/transacao.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  // O método 'call' permite usar a classe como uma função: getTransactions()
  Future<List<Transacao>> call() {
    return repository.getTransactions();
  }
}