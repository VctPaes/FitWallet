import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../dtos/usuario_dto.dart';

// 1. Definição da Interface (Contrato)
abstract class UsuarioRemoteDataSource {
  Future<UsuarioDTO?> getProfile();
  Future<void> updateProfile(UsuarioDTO user);
}

// 2. Implementação Concreta
class UsuarioRemoteDataSourceImpl implements UsuarioRemoteDataSource {
  final SupabaseClient client;
  
  UsuarioRemoteDataSourceImpl(this.client);

  @override
  Future<UsuarioDTO?> getProfile() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await client.from('profiles').select().eq('id', userId).maybeSingle();
      
      if (data == null) return null;
      return UsuarioDTO.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('UsuarioRemote: Erro ao buscar perfil: $e');
      // Retorna null para que o repo use o cache local
      return null;
    }
  }

  @override
  Future<void> updateProfile(UsuarioDTO user) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      // Garante que estamos atualizando o ID correto
      // O DTO pode ter um ID local gerado, mas no remoto usamos o UID do Auth
      final dataToUpdate = user.toJson();
      dataToUpdate['id'] = userId; 

      await client.from('profiles').upsert(dataToUpdate);
      
      if (kDebugMode) print('UsuarioRemote: Perfil atualizado no servidor.');
    } catch (e) {
      if (kDebugMode) print('UsuarioRemote: Erro ao atualizar perfil: $e');
      throw Exception('Erro de sync perfil: $e');
    }
  }
}