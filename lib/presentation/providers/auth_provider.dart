/// Provider de autenticación con Supabase.
/// Refactored to use Clean Architecture repositories.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository) {
    _init();
  }

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
    _authRepository.listenToAuthStateChanges();
    // Listen to auth state changes from Supabase directly for immediate updates
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        _isAuthenticated = true;
        _currentUser = _authRepository.getCurrentUser();
        if (_currentUser != null) {
          await _checkAdditionalData(_currentUser!.id);
        }
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
      _hasAdditionalData = await _authRepository.checkAdditionalData(userId);

      // Update user with role information
      if (_currentUser != null) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          final profile = await Supabase.instance.client
              .from('perfiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

          if (profile != null) {
            final roleStr = profile['rol'] as String? ?? 'usuario';
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
        }
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

      final success = await _authRepository.saveAdditionalData(
        userId: _currentUser!.id,
        firstName: firstName,
        lastName: lastName,
        role: role,
        career: career,
        profile: profile,
        photoUrl: photoUrl,
      );

      if (success) {
        _hasAdditionalData = true;
      }

      _isLoading = false;
      notifyListeners();
      return success;
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
      final success = await _authRepository.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
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
      final success = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
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
      await _authRepository.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al iniciar sesión con Google: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
