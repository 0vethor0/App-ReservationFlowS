/// Implementation of AuthRepository.
///
/// Connects AuthRemoteDataSource to domain layer.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await remoteDataSource.signInWithEmail(email, password);
      return true;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await remoteDataSource.signInWithGoogle();
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  UserEntity? getCurrentUser() {
    final session = remoteDataSource.getCurrentSession();
    if (session == null) return null;

    return UserEntity(
      id: session.user.id,
      fullName: session.user.userMetadata?['full_name'] as String? ?? 'Usuario',
      email: session.user.email ?? '',
      avatarUrl: session.user.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  Future<bool> checkAdditionalData(String userId) async {
    try {
      final profile = await remoteDataSource.getUserProfile(userId);

      if (profile == null) return false;

      final primerNombre = profile['primer_nombre']?.toString().trim() ?? '';
      final primerApellido =
          profile['primer_apellido']?.toString().trim() ?? '';
      final carrera = profile['carrera']?.toString().trim() ?? '';
      final especialidad = profile['especialidad']?.toString().trim() ?? '';

      return primerNombre.isNotEmpty &&
          primerApellido.isNotEmpty &&
          carrera.isNotEmpty &&
          especialidad.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> saveAdditionalData({
    required String userId,
    required String firstName,
    required String lastName,
    required String role,
    required String career,
    required String profile,
    String? photoUrl,
  }) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) throw Exception('No user logged in');

      await remoteDataSource.saveUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        role: role,
        career: career,
        profile: profile,
        photoUrl: photoUrl,
        email: currentUser.email,
      );

      return true;
    } catch (e) {
      throw Exception('Error saving profile: $e');
    }
  }

  @override
  void listenToAuthStateChanges() {
    remoteDataSource.listenToAuthState().listen((_) {
      // Auth state changes are handled by the provider layer
    });
  }

  @override
  Stream<UserStatus> watchCurrentUserStatus(String uid) {
    return remoteDataSource.watchCurrentUserStatus(uid);
  }
}
