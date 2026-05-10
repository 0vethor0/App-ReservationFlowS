/// Provider de autenticación con Supabase.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/entities.dart';

import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() : _supabase = Supabase.instance.client {
    _init();
  }

  final SupabaseClient _supabase;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _hasAdditionalData = false;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasAdditionalData => _hasAdditionalData;

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        _isAuthenticated = true;
        _currentUser = UserEntity(
          id: session.user.id,
          fullName:
              session.user.userMetadata?['full_name'] as String? ?? 'Usuario',
          email: session.user.email ?? '',
          phone: session.user.phone,
          avatarUrl: session.user.userMetadata?['avatar_url'] as String?,
        );
        await _checkAdditionalData(session.user.id);
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        _hasAdditionalData = false;
      }
      notifyListeners();
    });
  }

  Future<void> _checkAdditionalData(String userId) async {
    try {
      var response = await _supabase
          .from('perfiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        final session = _supabase.auth.currentSession;
        if (session != null && session.expiresAt != null) {
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
          if (DateTime.now().isAfter(expiresAt)) {
            debugPrint('DEBUG: Token expirado, intentando refresh...');
            try {
              await _supabase.auth.refreshSession();
              response = await _supabase
                  .from('perfiles')
                  .select()
                  .eq('id', userId)
                  .maybeSingle();
            } catch (refreshError) {
              debugPrint('DEBUG: Error al refresh token: $refreshError');
            }
          }
        }
      }

      if (response != null) {
        final primerNombre = response['primer_nombre']?.toString().trim() ?? '';
        final primerApellido =
            response['primer_apellido']?.toString().trim() ?? '';
        final carrera = response['carrera']?.toString().trim() ?? '';
        final especialidad = response['especialidad']?.toString().trim() ?? '';

        _hasAdditionalData =
            primerNombre.isNotEmpty &&
            primerApellido.isNotEmpty &&
            carrera.isNotEmpty &&
            especialidad.isNotEmpty;
      } else {
        _hasAdditionalData = false;
      }

      if (response != null && _currentUser != null) {
        final roleStr = response['rol'] as String? ?? 'usuario';

        final preciseRole = roleStr == 'super-admin'
            ? UserRole.superAdmin
            : (roleStr == 'admin' ? UserRole.admin : UserRole.user);

        _currentUser = UserEntity(
          id: _currentUser!.id,
          fullName: _currentUser!.fullName,
          email: _currentUser!.email,
          phone: _currentUser!.phone,
          avatarUrl: _currentUser!.avatarUrl,
          department: _currentUser!.department,
          role: preciseRole,
        );
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('JWT expired') || errorStr.contains('401') || errorStr.contains('Unauthorized')) {
        debugPrint('DEBUG: Token expirado, intentando refresh de sesión...');
        try {
          await _supabase.auth.refreshSession();
          final response = await _supabase
              .from('perfiles')
              .select()
              .eq('id', userId)
              .maybeSingle();
          
          if (response != null) {
            final primerNombre = response['primer_nombre']?.toString().trim() ?? '';
            final primerApellido = response['primer_apellido']?.toString().trim() ?? '';
            final carrera = response['carrera']?.toString().trim() ?? '';
            final especialidad = response['especialidad']?.toString().trim() ?? '';

            _hasAdditionalData =
                primerNombre.isNotEmpty &&
                primerApellido.isNotEmpty &&
                carrera.isNotEmpty &&
                especialidad.isNotEmpty;
          } else {
            _hasAdditionalData = false;
          }
        } catch (refreshError) {
          debugPrint('DEBUG: Error al refresh token: $refreshError');
          _hasAdditionalData = false;
        }
      } else {
        debugPrint('DEBUG: Error cargando perfil: $e');
        _error = 'Error cargando perfil: $e';
        _hasAdditionalData = false;
      }
    }
  }

  Future<bool> saveAdditionalData({
    required String firstName,
    required String lastName,
    required String role,
    required String career,
    required String profile,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser == null) throw Exception('No user logged in');

      await _supabase.from('perfiles').upsert({
        'id': _currentUser!.id,
        'primer_nombre': firstName,
        'primer_apellido': lastName,
        'rol': _currentUser?.role == UserRole.admin ? 'admin' : 'usuario',
        'correo': _currentUser!.email,
        'foto_url': photoUrl ?? '',
        'carrera': career,
        'especialidad': profile,
      });

      _hasAdditionalData = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error saving profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error inesperado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error inesperado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://reset-callback/',
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al iniciar sesión con Google: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
