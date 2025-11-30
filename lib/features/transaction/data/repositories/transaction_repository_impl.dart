import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../dtos/transacao_dto.dart';
import '../mappers/transacao_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final TransacaoMapper mapper;

  TransactionRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,
    this.mapper,
  );

  @override
  Future<List<Transacao>> loadFromCache() async {
    final dtos = await localDataSource.getTransactions();
    return dtos
        .where((dto) => dto.deletedAt == null)
        .map((dto) => mapper.toEntity(dto))
        .toList();
  }

  @override
  Future<int> syncFromServer() async {
    try {
      // 1. PUSH: Envia o que está pendente localmente antes de baixar
      await _syncPendingChanges();

      // 2. PULL: Baixa apenas o que mudou (Incremental)
      final lastSync = await localDataSource.getLastSyncTime();
      final newRemoteDtos = await remoteDataSource.getTransactions(after: lastSync);

      if (newRemoteDtos.isNotEmpty) {
        // Mescla os dados novos com o cache local
        await _mergeRemoteData(newRemoteDtos);
        
        // Atualiza timestamp do último sync (usa o horário atual do dispositivo ou do último item)
        await localDataSource.saveLastSyncTime(DateTime.now().toIso8601String());
      }

      return newRemoteDtos.length;
    } catch (e) {
      print('Sync falhou (modo offline mantido): $e');
      return 0;
    }
  }

  Future<void> _syncPendingChanges() async {
    final localDtos = await localDataSource.getTransactions();
    // Filtra apenas os que estão marcados como não sincronizados
    final pending = localDtos.where((t) => !t.sincronizado).toList();

    for (final dto in pending) {
      try {
        // Tenta enviar novamente
        // Nota: Em um cenário real complexo, você verificaria se é insert/update/delete
        // Aqui assumimos insert/update baseados na lógica simplificada
        await remoteDataSource.addTransaction(dto); // Ou upsert se suportado
        
        // Se sucesso, marca como sincronizado localmente
        final index = localDtos.indexWhere((t) => t.id == dto.id);
        if (index != -1) {
          localDtos[index] = dto.copyWith(sincronizado: true);
        }
      } catch (e) {
        print('Falha ao sincronizar item pendente ${dto.titulo}: $e');
        // Continua para o próximo item
      }
    }
    // Salva o estado atualizado (itens marcados como true)
    await localDataSource.saveTransactions(localDtos);
  }

  Future<void> _mergeRemoteData(List<TransacaoDTO> newRemoteData) async {
    final localDtos = await localDataSource.getTransactions();
    
    for (final remoteItem in newRemoteData) {
      final index = localDtos.indexWhere((l) => l.id == remoteItem.id);
      
      // Se o item remoto tem deletedAt, removemos do local definitivamente (ou marcamos)
      // Aqui, para limpar o armazenamento, vamos remover da lista local
      if (remoteItem.deletedAt != null) {
        if (index != -1) {
          localDtos.removeAt(index);
        }
      } else {
        // Se não está deletado, atualiza ou insere
        if (index != -1) {
          localDtos[index] = remoteItem;
        } else {
          localDtos.insert(0, remoteItem);
        }
      }
    }
    await localDataSource.saveTransactions(localDtos);
  }

  // --- CRUD com Fila ---

  @override
  Future<void> addTransaction(Transacao transacao) async {
    // 1. Cria DTO já assumindo falha (sincronizado = false)
    // Isso garante que se a internet cair no meio do try, ele já está na fila
    var dto = mapper.toDto(transacao).copyWith(sincronizado: false);

    // 2. Salva Local (Instantâneo)
    final localDtos = await localDataSource.getTransactions();
    localDtos.insert(0, dto);
    await localDataSource.saveTransactions(localDtos);

    // 3. Tenta Enviar
    try {
      await remoteDataSource.addTransaction(dto);
      
      // Se deu certo, atualiza local para true
      dto = dto.copyWith(sincronizado: true);
      localDtos[0] = dto; // O item 0 é o que acabamos de inserir
      await localDataSource.saveTransactions(localDtos);
    } catch (e) {
      print('Sem internet. Salvo localmente para sync futuro.');
      // Não faz nada, pois já salvamos como false no passo 2
    }
  }

  @override
  Future<void> updateTransaction(Transacao transacao) async {
    var dto = mapper.toDto(transacao).copyWith(sincronizado: false);

    final localDtos = await localDataSource.getTransactions();
    final index = localDtos.indexWhere((t) => t.id == transacao.id);
    if (index != -1) {
      localDtos[index] = dto;
      await localDataSource.saveTransactions(localDtos);
    }

    try {
      await remoteDataSource.updateTransaction(dto);
      // Sucesso: marca como true
      if (index != -1) {
        localDtos[index] = dto.copyWith(sincronizado: true);
        await localDataSource.saveTransactions(localDtos);
      }
    } catch (e) {
      print('Update offline salvo.');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final localDtos = await localDataSource.getTransactions();
    final index = localDtos.indexWhere((t) => t.id == id);
    
    if (index != -1) {
      final deletedItem = localDtos[index].copyWith(
        sincronizado: false,
        deletedAt: DateTime.now().toIso8601String(),
      );
      localDtos[index] = deletedItem;
      await localDataSource.saveTransactions(localDtos);

      try {
        await remoteDataSource.deleteTransaction(id);
        
        localDtos[index] = deletedItem.copyWith(sincronizado: true);
        await localDataSource.saveTransactions(localDtos);
      } catch (e) {
        print('Delete offline. Marcado para envio posterior.');
      }
    }
  }
  
  @override
  Future<List<Transacao>> listAll() async {
    return loadFromCache();
  }
}