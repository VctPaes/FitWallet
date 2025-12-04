import 'package:flutter/material.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Verifica se existe um usuário logado no momento
  bool get isAuthenticated => getCurrentUserUseCase() != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null; // Limpa erros anteriores
    try {
      await signInUseCase(email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow; // Relança para a UI saber que falhou e exibir SnackBar se quiser
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String nome, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await signUpUseCase(nome, email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await signOutUseCase();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}