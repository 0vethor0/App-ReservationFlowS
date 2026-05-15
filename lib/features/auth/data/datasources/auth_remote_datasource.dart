/// Data source for authentication operations.
///
/// Handles all Supabase auth-related calls.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource(this.client);
  /// Realizar inicio de sesion con correo electronico y contraseña
  /// Sign in with email and password
  Future<AuthResponse>  signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Realizar registro con correo electronico y contraseña
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Realizar inicio de sesion con cuenta de Google
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://callback/',
    );
  }

  /// Realizar cierre de sesion
  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get current session
  /// obtener la sesion actual
  Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  /// obtener perfil de usuario desde la tabla perfiles
  /// Get user profile from perfiles table
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('perfiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  /// guardar perfil de usuario en la tabla perfiles
  /// Save user profile to perfiles table
  Future<void> saveUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String role,
    required String career,
    required String profile,
    String? photoUrl,
    required String email,
  }) async {
    await client.from('perfiles').upsert({
      'id': userId,
      'primer_nombre': firstName,
      'primer_apellido': lastName,
      'rol': role,
      'correo': email,
      'foto_url': photoUrl ?? '',
      'carrera': career,
      'especialidad': profile,
    });
  }

  /// Refrescar sesion
  /// Refresh session
  Future<Session> refreshSession() async {
    final response = await client.auth.refreshSession();
    return response.session!;
  }

  /// Escuchar cambios de estado de autenticacion
  /// Listen to auth state changes
  Stream<AuthState> listenToAuthState() {
    return client.auth.onAuthStateChange;
  }

  /// Observar cambios de estado de usuario en tiempo real
  /// Watch current user status changes in real-time
  Stream<UserStatus> watchCurrentUserStatus(String uid) {
    return client
        .from('perfiles')
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .map((maps) {
      if (maps.isEmpty) return UserStatus.pending;
      final statusStr = maps.first['status'] as String? ?? 'pending';
      return statusStr == 'approved'
          ? UserStatus.approved
          : (statusStr == 'rejected' ? UserStatus.rejected : UserStatus.pending);
    });
  }
}
