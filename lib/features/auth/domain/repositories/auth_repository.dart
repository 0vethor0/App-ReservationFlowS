/// Abstract repository interface for authentication.
///
/// Defines the contract for authentication operations.
library;

import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Realizar inicio de sesion con correo electronico y contraseña
  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password);

  /// Realizar registro con correo electronico y contraseña
  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  });
  
  /// Realizar inicio de sesion con Google OAuth
  /// Sign in with Google OAuth
  Future<void> signInWithGoogle();

  /// Realizar cierre de sesion
  /// Sign out current user
  Future<void> signOut();

  /// obtener el usuario actualmente autenticado
  /// Get current authenticated user
  UserEntity? getCurrentUser();

  /// Comprobar si el usuario tiene datos adicionales
  /// Check if user has additional profile data
  Future<bool> checkAdditionalData(String userId);

  /// Guardar datos adicionales del usuario
  /// Save additional user profile data
  Future<bool> saveAdditionalData({
    required String userId,
    required String firstName,
    required String lastName,
    required String role,
    required String career,
    required String profile,
    String? photoUrl,
  });

  /// Escuchar cambios de estado de autenticacion
  /// Listen to auth state changes
  void listenToAuthStateChanges();

  /// Observar cambios de estado de usuario en tiempo real  
  /// Watch current user approval status changes in real-time
  Stream<UserStatus> watchCurrentUserStatus(String uid);
}
