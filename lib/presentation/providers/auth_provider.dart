/// Provider de autenticación con Supabase.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/entities.dart';

import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

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
      final response = await _supabase
          .from('perfiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      _hasAdditionalData =
          response != null && response['primer_nombre'] != null;

      if (response != null && _currentUser != null) {
        final roleStr = response['rol'] as String? ?? 'usuario';
        final role = roleStr == 'admin' ? UserRole.admin : UserRole.user;

        _currentUser = UserEntity(
          id: _currentUser!.id,
          fullName: _currentUser!.fullName,
          email: _currentUser!.email,
          phone: _currentUser!.phone,
          avatarUrl: _currentUser!.avatarUrl,
          department: _currentUser!.department,
          role: role,
        );
      }
    } catch (e) {
      debugPrint('DEBUG: Error cargando perfil: $e');
      _error = 'Error cargando perfil: $e';
      _hasAdditionalData = false;
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
        'perfil': profile,
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
        redirectTo: 'com.beamreserve.beam_reserve://login-callback',
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
