import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart'; 
import '../mappers/transacao_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final TransacaoMapper mapper;

  TransactionRepositoryImpl(
    this.localDataSource, 
    this.remoteDataSource, 
    this.mapper
  );

  @override
  Future<List<Transacao>> loadFromCache() async {
    final dtos = await localDataSource.getTransactions();
    return dtos.map((dto) => mapper.toEntity(dto)).toList();
  }

  @override
  Future<int> syncFromServer() async {
    try {
      final remoteDtos = await remoteDataSource.getTransactions();
      await localDataSource.saveTransactions(remoteDtos);
      return remoteDtos.length;
    } catch (e) {
      print('Erro de sync: $e');
      return 0;
    }
  }

  @override
  Future<List<Transacao>> listAll() async {
    return loadFromCache();
  }

  // --- CRUD (Offline-First) ---

  @override
  Future<void> addTransaction(Transacao transacao) async {
    final dto = mapper.toDto(transacao);
    
    // 1. Salva Local
    final localDtos = await localDataSource.getTransactions();
    localDtos.insert(0, dto);
    await localDataSource.saveTransactions(localDtos);

    // 2. Tenta Remoto
    try {
      await remoteDataSource.addTransaction(dto);
    } catch (e) {
      print('Erro ao enviar para Supabase (Add): $e');
    }
  }

  @override
  Future<void> updateTransaction(Transacao transacao) async {
    final dto = mapper.toDto(transacao);

    // 1. Atualiza Local
    final dtos = await localDataSource.getTransactions();
    final index = dtos.indexWhere((t) => t.id == transacao.id);
    if (index != -1) {
      dtos[index] = dto;
      await localDataSource.saveTransactions(dtos);
    }

    // 2. Tenta Remoto
    try {
      await remoteDataSource.updateTransaction(dto);
    } catch (e) {
      print('Erro ao enviar para Supabase (Update): $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    // 1. Remove Local
    final dtos = await localDataSource.getTransactions();
    dtos.removeWhere((t) => t.id == id);
    await localDataSource.saveTransactions(dtos);

    // 2. Tenta Remoto
    try {
      await remoteDataSource.deleteTransaction(id);
    } catch (e) {
      print('Erro ao enviar para Supabase (Delete): $e');
    }
  }
}