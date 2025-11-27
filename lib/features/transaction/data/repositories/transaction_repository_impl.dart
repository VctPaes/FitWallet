import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../mappers/transacao_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource dataSource;
  final TransacaoMapper mapper;

  TransactionRepositoryImpl(this.dataSource, this.mapper);

  @override
  Future<List<Transacao>> getTransactions() async {
    final dtos = await dataSource.getTransactions();
    // Converte a lista de DTOs para Entidades usando o Mapper
    return dtos.map((dto) => mapper.toEntity(dto)).toList();
  }

  @override
  Future<void> addTransaction(Transacao transacao) async {
    // 1. Busca a lista atual
    final dtos = await dataSource.getTransactions();
    
    // 2. Converte a nova transação para DTO e adiciona no início da lista
    dtos.insert(0, mapper.toDto(transacao));
    
    // 3. Salva a lista atualizada
    await dataSource.saveTransactions(dtos);
  }

  @override
  Future<void> updateTransaction(Transacao transacao) async {
    final dtos = await dataSource.getTransactions();
    
    // Encontra o índice da transação pelo ID
    final index = dtos.indexWhere((t) => t.id == transacao.id);
    
    if (index != -1) {
      dtos[index] = mapper.toDto(transacao);
      await dataSource.saveTransactions(dtos);
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final dtos = await dataSource.getTransactions();
    
    // Remove o item que tem o ID correspondente
    dtos.removeWhere((t) => t.id == id);
    
    await dataSource.saveTransactions(dtos);
  }
}