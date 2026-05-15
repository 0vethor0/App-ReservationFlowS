/// Use case for signing up with email and password.
library;

import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<bool> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return repository.signUpWithEmail(
      email: email,
      password: password,
    );
  }
}
