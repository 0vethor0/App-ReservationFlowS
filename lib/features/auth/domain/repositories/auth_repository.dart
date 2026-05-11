/// Abstract repository interface for authentication.
///
/// Defines the contract for authentication operations.
library;

import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle();

  /// Sign out current user
  Future<void> signOut();

  /// Get current authenticated user
  UserEntity? getCurrentUser();

  /// Check if user has additional profile data
  Future<bool> checkAdditionalData(String userId);

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

  /// Listen to auth state changes
  void listenToAuthStateChanges();
}
