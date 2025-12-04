import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../dtos/transacao_dto.dart';
import '../mappers/transacao_mapper.dart';
import 'package:flutter/foundation.dart';

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
    if (kDebugMode) print('TransactionRepository: Iniciando Sincronização...');
    try {
      // 1. Push
      await _syncPendingChanges();

      // 2. Pull
      final lastSync = await localDataSource.getLastSyncTime();
      if (kDebugMode) print('TransactionRepository: Último sync em $lastSync');

      final newRemoteDtos =
          await remoteDataSource.getTransactions(after: lastSync);

      if (newRemoteDtos.isNotEmpty) {
        if (kDebugMode)
          print(
              'TransactionRepository: Processando ${newRemoteDtos.length} novos itens...');
        await _mergeRemoteData(newRemoteDtos);

        // Atualiza timestamp
        final now = DateTime.now().toIso8601String();
        await localDataSource.saveLastSyncTime(now);
      }

      return newRemoteDtos.length;
    } catch (e) {
      if (kDebugMode)
        print('TransactionRepository: Erro no Sync (Modo Offline mantido): $e');
      return 0; // Falha silenciosa para o usuário, mas logada
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
    var dto = mapper.toDto(transacao).copyWith(sincronizado: false);

    final localDtos = await localDataSource.getTransactions();
    localDtos.insert(0, dto);
    await localDataSource.saveTransactions(localDtos);

    try {
      await remoteDataSource.addTransaction(dto);

      dto = dto.copyWith(sincronizado: true);
      localDtos[0] = dto;
      await localDataSource.saveTransactions(localDtos);
    } catch (e) {
      if (kDebugMode) {
        print('Sem internet. Salvo localmente para sync futuro.');
      }
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
