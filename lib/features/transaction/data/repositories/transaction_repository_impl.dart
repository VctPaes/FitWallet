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
      await _syncPendingChanges();

      final lastSync = await localDataSource.getLastSyncTime();
      if (kDebugMode) print('TransactionRepository: Último sync em $lastSync');

      final newRemoteDtos =
          await remoteDataSource.getTransactions(after: lastSync);

      if (newRemoteDtos.isNotEmpty) {
        if (kDebugMode) {
          print(
              'TransactionRepository: Processando ${newRemoteDtos.length} novos itens...');
        }
        await _mergeRemoteData(newRemoteDtos);

        final maxUpdatedAt = newRemoteDtos
            .map((e) => e.updatedAt)
            .where((e) => e != null)
            .fold<DateTime>(DateTime.fromMillisecondsSinceEpoch(0),
                (prev, curr) {
          final dt = DateTime.parse(curr!);
          return dt.isAfter(prev) ? dt : prev;
        });

        if (maxUpdatedAt.year > 1970) {
          await localDataSource
              .saveLastSyncTime(maxUpdatedAt.toIso8601String());
        } else {
          await localDataSource
              .saveLastSyncTime(DateTime.now().toIso8601String());
        }
      }

      return newRemoteDtos.length;
    } catch (e) {
      if (kDebugMode) {
        print('TransactionRepository: Erro no Sync (Modo Offline mantido): $e');
      }
      return 0;
    }
  }

  Future<void> _syncPendingChanges() async {
    final localDtos = await localDataSource.getTransactions();

    final pending = localDtos.where((t) => !t.sincronizado).toList();

    if (pending.isEmpty) return;

    try {
      if (kDebugMode)
        print(
            'TransactionRepository: Enviando ${pending.length} itens pendentes...');

      await remoteDataSource.upsertTransactions(pending);

      for (var i = 0; i < localDtos.length; i++) {
        if (!localDtos[i].sincronizado) {
          localDtos[i] = localDtos[i].copyWith(sincronizado: true);
        }
      }

      await localDataSource.saveTransactions(localDtos);
    } catch (e) {
      if (kDebugMode) print('TransactionRepository: Falha no push em lote: $e');
    }
  }

  Future<void> _mergeRemoteData(List<TransacaoDTO> newRemoteData) async {
    final localDtos = await localDataSource.getTransactions();

    for (final remoteItem in newRemoteData) {
      final index = localDtos.indexWhere((l) => l.id == remoteItem.id);

      if (remoteItem.deletedAt != null) {
        if (index != -1) {
          localDtos.removeAt(index);
        }
      } else {
        if (index != -1) {
          localDtos[index] = remoteItem;
        } else {
          localDtos.insert(0, remoteItem);
        }
      }
    }
    await localDataSource.saveTransactions(localDtos);
  }

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
