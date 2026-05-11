/// Data source for authentication operations.
///
/// Handles all Supabase auth-related calls.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource(this.client);

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://reset-callback/',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get current session
  Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  /// Get user profile from perfiles table
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('perfiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

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

  /// Refresh session
  Future<Session> refreshSession() async {
    final response = await client.auth.refreshSession();
    return response.session!;
  }

  /// Listen to auth state changes
  Stream<AuthState> listenToAuthState() {
    return client.auth.onAuthStateChange;
  }
}
