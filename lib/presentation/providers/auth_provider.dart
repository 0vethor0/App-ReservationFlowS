/// Provider de autenticación con Supabase.
/// Refactored to use Clean Architecture repositories.
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/storage_repository.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageRepository? _storageRepository;

  AuthProvider(this._authRepository, [this._storageRepository]) {
    _init();
  }

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _hasAdditionalData = false;
  UserStatus? _currentUserStatus;
  StreamSubscription? _statusSubscription;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasAdditionalData => _hasAdditionalData;
  UserStatus? get currentUserStatus => _currentUserStatus;

  void _init() {
    _authRepository.listenToAuthStateChanges();
    // Listen to auth state changes from Supabase directly for immediate updates
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          if (session != null) {
            _isAuthenticated = true;
            _currentUser = _authRepository.getCurrentUser();
            if (_currentUser != null) {
              await _checkAdditionalData(_currentUser!.id);
            }
            notifyListeners();
          }
          break;
        case AuthChangeEvent.signedOut:
          _isAuthenticated = false;
          _currentUser = null;
          _hasAdditionalData = false;
          _currentUserStatus = null;
          notifyListeners();
          break;
        default:
          break;
      }

    });
  }

Future<void> _checkAdditionalData(String userId) async {
    try {
      // 1. Verificamos si existen datos básicos en el repositorio
      _hasAdditionalData = await _authRepository.checkAdditionalData(userId);
      
      if (_currentUser == null) return;

      // 2. Intentamos obtener el perfil detallado desde la base de datos
      // Nota: Idealmente, esta consulta debería estar en el AuthRepository
      final profile = await Supabase.instance.client
          .from('perfiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        // Mapeamos los Strings de la DB a nuestros Enums (UserRole y UserStatus)
        final preciseRole = _mapRole(profile['rol'] as String?);
        final status = _mapStatus(profile['status'] as String?);

        // Actualizamos la entidad con la información completa
        _currentUser = UserEntity(
          id: _currentUser!.id,
          fullName: _currentUser!.fullName,
          email: _currentUser!.email,
          avatarUrl: _currentUser!.avatarUrl,
          department: _currentUser!.department,
          role: preciseRole,
          status: status,
        );

        _currentUserStatus = status;
      }

      // 3. Gestionamos la suscripción en tiempo real para cambios de estado
      await _setupStatusSubscription(userId);

      // 4. Notificamos a los listeners (como el Router) que los datos están listos
      notifyListeners();

    } catch (e) {
      debugPrint('DEBUG: Error en _checkAdditionalData: $e');
      _error = 'Error al cargar información de perfil';
      _hasAdditionalData = false;
      notifyListeners();
    }
  }

  // --- Funciones auxiliares para limpiar el código principal ---

  UserRole _mapRole(String? roleStr) {
    switch (roleStr) {
      case 'super-admin': return UserRole.superAdmin;
      case 'admin':       return UserRole.admin;
      default:            return UserRole.user;
    }
  }

  UserStatus _mapStatus(String? statusStr) {
    switch (statusStr) {
      case 'approved': return UserStatus.approved;
      case 'rejected': return UserStatus.rejected;
      default:         return UserStatus.pending;
    }
  }

  Future<void> _setupStatusSubscription(String userId) async {
    await _statusSubscription?.cancel();
    _statusSubscription = _authRepository
        .watchCurrentUserStatus(userId)
        .listen((newStatus) {
      if (_currentUser != null && _currentUserStatus != newStatus) {
        _currentUserStatus = newStatus;
        _currentUser = UserEntity(
          id: _currentUser!.id,
          fullName: _currentUser!.fullName,
          email: _currentUser!.email,
          avatarUrl: _currentUser!.avatarUrl,
          department: _currentUser!.department,
          role: _currentUser!.role,
          status: newStatus,
        );
        notifyListeners();
      }
    });
  }

  Future<bool> saveAdditionalData({
    required String firstName,
    required String lastName,
    required String role,
    required String career,
    required String profile,
    File? photoFile,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser == null) throw Exception('No hay ningún usuario conectado');

      String? finalPhotoUrl = photoUrl;

      // Upload photo if file is provided
      if (photoFile != null && _storageRepository != null) {
        finalPhotoUrl = await _storageRepository.uploadProfilePhoto(
          userId: _currentUser!.id,
          photoFile: photoFile,
        );
      }

      final success = await _authRepository.saveAdditionalData(
        userId: _currentUser!.id,
        firstName: firstName,
        lastName: lastName,
        role: role,
        career: career,
        profile: profile,
        photoUrl: finalPhotoUrl,
      );

      if (success) {
        _hasAdditionalData = true;
        // Refresh user data after saving
        await _checkAdditionalData(_currentUser!.id);
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
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
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

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
