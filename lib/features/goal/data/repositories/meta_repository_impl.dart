import 'package:flutter/foundation.dart';
import '../../domain/entities/meta.dart';
import '../../domain/repositories/meta_repository.dart';
import '../datasources/meta_local_datasource.dart';
import '../datasources/meta_remote_datasource.dart';
import '../dtos/meta_dto.dart';
import '../mappers/meta_mapper.dart';

class MetaRepositoryImpl implements MetaRepository {
  final MetaLocalDataSource localDataSource;
  final MetaRemoteDataSource remoteDataSource;
  final MetaMapper mapper;

  MetaRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,
    this.mapper,
  );

  @override
  Future<Meta> getMeta() async {
    try {
      final dto = await localDataSource.getMeta();
      if (dto != null) {
        return mapper.toEntity(dto);
      }
    } catch (e) {
      if (kDebugMode) print('MetaRepository: Erro ao ler cache local: $e');
    }

    return Meta(id: 'meta_semanal', valor: 150.0, periodo: 'semanal');
  }

  Future<void> syncMeta() async {
    if (kDebugMode) print('MetaRepository: Iniciando sync de Meta...');
    
    try {
      final remoteDto = await remoteDataSource.getMeta();
      
      if (remoteDto != null) {
        if (kDebugMode) print('MetaRepository: Meta remota encontrada. Atualizando local.');
        await localDataSource.saveMeta(remoteDto);
      } else {
        final localDto = await localDataSource.getMeta();
        if (localDto != null) {
          if (kDebugMode) print('MetaRepository: Servidor vazio. Enviando meta local.');
          await remoteDataSource.upsertMeta(localDto);
        }
      }
    } catch (e) {
      if (kDebugMode) print('MetaRepository: Falha no sync (modo offline): $e');
    }
  }

  @override
  Future<void> updateMeta(double novoValor) async {
    final novaMetaDto = MetaDTO(
      id: 'meta_semanal', 
      valor: novoValor, 
      periodo: 'semanal'
    );

    await localDataSource.saveMeta(novaMetaDto);
    if (kDebugMode) print('MetaRepository: Meta salva localmente.');

    try {
      await remoteDataSource.upsertMeta(novaMetaDto);
      if (kDebugMode) print('MetaRepository: Meta sincronizada com servidor.');
    } catch (e) {
      if (kDebugMode) print('MetaRepository: Erro ao enviar meta (será enviada no próximo sync): $e');
    }
  }
}