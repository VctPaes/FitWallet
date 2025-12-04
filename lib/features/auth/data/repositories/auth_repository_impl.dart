import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await remoteDataSource.signIn(email, password);
    } catch (e) {
      if (kDebugMode) print('AuthRepository: Erro no login: $e');
      throw Exception('Falha ao entrar. Verifique email e senha.');
    }
  }

  @override
  Future<void> signUp(String nome, String email, String password) async {
    try {
      await remoteDataSource.signUp(nome, email, password);
    } catch (e) {
      if (kDebugMode) print('AuthRepository: Erro no cadastro: $e');
      throw Exception('Não foi possível criar a conta. Tente novamente.');
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  User? getCurrentUser() {
    return remoteDataSource.currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges => remoteDataSource.authStateChanges;
}