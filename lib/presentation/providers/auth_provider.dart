/// Provider de autenticación con Supabase.
/// Refactored to use Clean Architecture repositories.
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/notification/notification_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/storage_repository.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageRepository? _storageRepository;
  final NotificationService? _notificationService;

  AuthProvider(
    this._authRepository, [
    this._storageRepository,
    this._notificationService,
  ]) {
    _init();
  }

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // === RACE CONDITION FIX: explicit loading state for additional data check ===
  bool _isLoadingAdditionalData = true;
  bool _hasAdditionalData = false;

  UserStatus? _currentUserStatus;
  StreamSubscription? _statusSubscription;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasAdditionalData => _hasAdditionalData;
  bool get isLoadingAdditionalData => _isLoadingAdditionalData;
  UserStatus? get currentUserStatus => _currentUserStatus;

  void _init() {
    _authRepository.listenToAuthStateChanges();

    // Check if session already exists at startup (avoids race on hot restart)
    final existingUser = _authRepository.getCurrentUser();
    if (existingUser != null) {
      _isAuthenticated = true;
      _currentUser = existingUser;
      debugPrint(
        '[${DateTime.now()}] AuthProvider._init - Sesión existente detectada: ${_currentUser!.id}',
      );
      _checkAdditionalData(_currentUser!.id);
      _saveDeviceToken(); // fire-and-forget: guarda el token FCM
    } else {
      // No session: no need to wait for data
      _isLoadingAdditionalData = false;
    }

    _authRepository.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint('[${DateTime.now()}] AuthProvider - Evento: $event');

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          if (session != null) {
            _isAuthenticated = true;
            _currentUser = _authRepository.getCurrentUser();
            if (_currentUser != null) {
              debugPrint(
                '[${DateTime.now()}] AuthProvider - Usuario: ${_currentUser!.id}. Verificando datos...',
              );
              await _checkAdditionalData(_currentUser!.id);
              _saveDeviceToken(); // fire-and-forget: guarda el token FCM tras login
            }
            notifyListeners();
          }
          break;
        case AuthChangeEvent.signedOut:
          _isAuthenticated = false;
          _currentUser = null;
          _hasAdditionalData = false;
          _isLoadingAdditionalData = false;
          _currentUserStatus = null;
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _checkAdditionalData(String userId) async {
    debugPrint(
      '[${DateTime.now()}] _checkAdditionalData - Iniciando para: $userId',
    );
    _isLoadingAdditionalData = true;
    notifyListeners();

    try {
      _hasAdditionalData = await _authRepository.checkAdditionalData(userId);

      if (_currentUser == null) return;

      final profile = await _authRepository.getUserProfileComplete(userId);

      if (profile != null) {
        final preciseRole = _mapRole(profile.rol);
        final status = _mapStatus(profile.status);

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

      await _setupStatusSubscription(userId);

      debugPrint(
        '[${DateTime.now()}] _checkAdditionalData - hasAdditionalData: $_hasAdditionalData | status: $_currentUserStatus',
      );
    } catch (e) {
      debugPrint('[${DateTime.now()}] _checkAdditionalData - ERROR: $e');
      _error = 'Error al cargar información de perfil';
      _hasAdditionalData = false;
    } finally {
      _isLoadingAdditionalData = false;
      notifyListeners();
    }
  }

  /// Fuerza una re-verificación completa desde la base de datos del estado
  /// de datos adicionales del usuario. Útil cuando el usuario llega a la
  /// pantalla de datos adicionales y se quiere confirmar que efectivamente
  /// siguen faltando (o si ya fueron completados desde otro lugar).
  Future<void> refreshAdditionalDataCheck() async {
    if (_currentUser == null) return;
    debugPrint(
      '[${DateTime.now()}] refreshAdditionalDataCheck - Forzando re-verificación desde DB',
    );
    await _checkAdditionalData(_currentUser!.id);
  }

  // --- Funciones auxiliares para limpiar el código principal ---

  UserRole _mapRole(String? roleStr) {
    switch (roleStr) {
      case 'super-admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  UserStatus _mapStatus(String? statusStr) {
    switch (statusStr) {
      case 'approved':
        return UserStatus.approved;
      case 'rejected':
        return UserStatus.rejected;
      default:
        return UserStatus.pending;
    }
  }

  Future<void> _saveDeviceToken() async {
    try {
      final token = await _notificationService?.getDeviceToken();
      if (token != null && _currentUser != null) {
        await _authRepository.updateFcmToken(
          userId: _currentUser!.id,
          token: token,
        );
        debugPrint('[${DateTime.now()}] AuthProvider - FCM token guardado');
      }
    } catch (e) {
      debugPrint(
        '[${DateTime.now()}] AuthProvider - Error guardando FCM token: $e',
      );
    }
  }

  Future<void> _setupStatusSubscription(String userId) async {
    await _statusSubscription?.cancel();
    _statusSubscription = _authRepository.watchCurrentUserStatus(userId).listen(
      (newStatus) {
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
      },
    );
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
      if (_currentUser == null) {
        throw Exception('No hay ningún usuario conectado');
      }

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
        // UPDATE LOCAL STATE IMMEDIATELY to avoid race condition with router
        _hasAdditionalData = true;
        _currentUserStatus = UserStatus.pending;
        _isLoadingAdditionalData = false;
        notifyListeners();

        // Then refresh from database in background (non-blocking for UI)
        await _checkAdditionalData(_currentUser!.id);
        debugPrint(
          '[${DateTime.now()}] [AUTH] Datos guardados con éxito. _hasAdditionalData: $_hasAdditionalData',
        );
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
