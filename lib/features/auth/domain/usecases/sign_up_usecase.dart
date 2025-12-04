import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<void> call(String nome, String email, String password) {
    return repository.signUp(nome, email, password);
  }
}