import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../dtos/meta_dto.dart';

abstract class MetaRemoteDataSource {
  Future<MetaDTO?> getMeta();
  Future<void> upsertMeta(MetaDTO meta);
}

class MetaRemoteDataSourceImpl implements MetaRemoteDataSource {
  final SupabaseClient client;

  MetaRemoteDataSourceImpl(this.client);

  @override
  Future<MetaDTO?> getMeta() async {
    if (kDebugMode) print('MetaRemoteDatasource: Buscando meta remota...');
    try {
      final response = await client.from('metas').select().limit(1).maybeSingle();
      
      if (response == null) return null;
      return MetaDTO.fromJson(response);
    } catch (e) {
      if (kDebugMode) print('MetaRemoteDatasource: Erro ao buscar meta: $e');
      return null;
    }
  }

  @override
  Future<void> upsertMeta(MetaDTO meta) async {
    try {
      await client.from('metas').upsert(meta.toJson());
      if (kDebugMode) print('MetaRemoteDatasource: Meta enviada com sucesso.');
    } catch (e) {
      if (kDebugMode) print('MetaRemoteDatasource: Erro ao enviar meta: $e');
      throw Exception('Erro de sync meta');
    }
  }
}