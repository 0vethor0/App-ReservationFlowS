/// Data source for authentication operations.
///
/// Handles all Supabase auth-related calls.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource(this.client);

  /// Realizar inicio de sesion con correo electronico y contraseña
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Realizar registro con correo electronico y contraseña
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(email: email, password: password);
  }

  /// Realizar inicio de sesion con Google OAuth.
  ///
  /// FLUJO COMPLETO:
  /// 1. supabase_flutter genera el code_verifier PKCE y lo guarda en SharedPreferences.
  /// 2. Abre el navegador con el flujo OAuth de Google.
  /// 3. Google autentica al usuario y devuelve el control a Supabase.
  /// 4. Supabase redirige al Site URL (landing page en tudominio.com/welcome)
  ///    con el parámetro ?code=XXXX (porque el redirectTo de abajo no está
  ///    en la lista de URLs permitidas del proyecto Supabase).
  /// 5. La landing page reenvía al usuario a:
  ///    io.supabase.flutter://callback/?code=XXXX
  /// 6. Android intercepta esa URI (intent-filter en AndroidManifest.xml)
  ///    y abre la app con el deep link.
  /// 7. supabase_flutter detecta el deep link automáticamente, extrae el code,
  ///    lo intercambia por una sesión usando el code_verifier guardado.
  /// 8. onAuthStateChange dispara AuthChangeEvent.signedIn.
  /// 9. AuthProvider detecta el evento y verifica datos adicionales del perfil.
  ///
  /// IMPORTANTE: El `redirectTo` aquí le indica a supabase_flutter qué
  /// esquema de deep link debe escuchar. NO cambiarlo por la URL de la
  /// landing page, ya que eso confundiría el manejo interno de PKCE.
  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://callback/',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Realizar cierre de sesion
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get current session
  Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  /// Obtener perfil de usuario desde la tabla perfiles
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('perfiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  /// Obtener perfil completo del usuario con todos los campos
  Future<UserProfileComplete?> getUserProfileComplete(String userId) async {
    final response = await client
        .from('perfiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return UserProfileComplete(
      primerNombre: response['primer_nombre'] as String? ?? '',
      primerApellido: response['primer_apellido'] as String? ?? '',
      carrera: response['carrera'] as String? ?? '',
      especialidad: response['especialidad'] as String? ?? '',
      rol: response['rol'] as String? ?? '',
      status: response['status'] as String? ?? 'pending',
    );
  }

  /// Guardar perfil de usuario en la tabla perfiles
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
  Future<Session> refreshSession() async {
    final response = await client.auth.refreshSession();
    return response.session!;
  }

  /// Escuchar cambios de estado de autenticacion
  Stream<AuthState> listenToAuthState() {
    return client.auth.onAuthStateChange;
  }

  /// Actualizar el token FCM del usuario en la tabla perfiles
  Future<void> updateFcmToken({
    required String userId,
    required String token,
  }) async {
    await client.from('perfiles').update({'fcm_token': token}).eq('id', userId);
  }

  /// Observar cambios de estado de usuario en tiempo real
  Stream<UserStatus> watchCurrentUserStatus(String uid) {
    return client.from('perfiles').stream(primaryKey: ['id']).eq('id', uid).map(
      (maps) {
        if (maps.isEmpty) return UserStatus.pending;
        final statusStr = maps.first['status'] as String? ?? 'pending';
        return statusStr == 'approved'
            ? UserStatus.approved
            : (statusStr == 'rejected'
                  ? UserStatus.rejected
                  : UserStatus.pending);
      },
    );
  }
}
