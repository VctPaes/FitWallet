import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  User? call() {
    return repository.getCurrentUser();
  }
}