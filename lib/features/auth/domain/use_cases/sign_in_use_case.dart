/// Use case for signing in with email and password.
library;

import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<bool> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}
