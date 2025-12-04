import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../dtos/usuario_dto.dart';

abstract class UsuarioRemoteDataSource {
  Future<UsuarioDTO?> getProfile();
  Future<void> updateProfile(UsuarioDTO user);
  Future<String> uploadAvatar(String userId, Uint8List imageBytes, String fileExtension);
}

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
      return null;
    }
  }

  @override
  Future<void> updateProfile(UsuarioDTO user) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      final dataToUpdate = user.toJson();
      dataToUpdate['id'] = userId; 

      await client.from('profiles').upsert(dataToUpdate);
      
      if (kDebugMode) print('UsuarioRemote: Perfil atualizado no servidor.');
    } catch (e) {
      if (kDebugMode) print('UsuarioRemote: Erro ao atualizar perfil: $e');
      throw Exception('Erro de sync perfil: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String userId, Uint8List imageBytes, String fileExtension) async {
    try {
      final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await client.storage.from('avatars').uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = client.storage.from('avatars').getPublicUrl(fileName);
      
      if (kDebugMode) print('UsuarioRemote: Upload concluído. URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      if (kDebugMode) print('UsuarioRemote: Erro no upload: $e');
      throw Exception('Falha ao enviar imagem para o servidor.');
    }
  }
}
