import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// Interface para facilitar testes (Mock)
abstract class AuthRemoteDataSource {
  Future<AuthResponse> signIn(String email, String password);
  Future<AuthResponse> signUp(String nome, String email, String password);
  Future<void> signOut();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
}

// Implementação Real
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    if (kDebugMode) print('AuthRemoteDataSource: Login para $email...');
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp(String nome, String email, String password) async {
    if (kDebugMode) print('AuthRemoteDataSource: Cadastro para $email...');
    
    // Enviamos o 'nome_completo' nos metadados para o Trigger do SQL usar
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'nome_completo': nome}, 
    );
  }

  @override
  Future<void> signOut() async {
    if (kDebugMode) print('AuthRemoteDataSource: Logout.');
    await client.auth.signOut();
  }

  @override
  User? get currentUser => client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}