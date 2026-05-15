/// Provider for user management operations.
///
/// Handles state for admin user approval workflows.
/// Este provider controla las operaciones de gestión de usuarios en el panel de administrador
/// Ademas, maneja el estado para flujos de trabajo de aprobacion de usuarios.
/// Y proporciona funcionalidades para aprobar o rechazar usuarios.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/pending_user_entity.dart';
import '../../domain/repositories/i_user_management_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  final IUserManagementRepository _repository;

  UserManagementProvider(this._repository) {
    _init();
  }

  List<PendingUserEntity> _pendingUsers = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<PendingUserEntity> get pendingUsers => _pendingUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    // Subscribe to real-time updates
    _subscription = _repository.watchPendingUsers().listen(
      (users) {
        _pendingUsers = users;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error al cargar usuarios: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Load pending users (initial load)
  Future<void> loadPendingUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingUsers = await _repository.getPendingUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar usuarios: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve a user
  Future<void> approveUser(String userId, BuildContext context) async {
    try {
      // Call the repository to approve the user (single call)
      await _repository.approveUser(userId);
      
      // If no exception was thrown, the operation was successful
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario aprobado exitosamente'),
            backgroundColor: Colors.green,
          ),
         
        );
         await loadPendingUsers();
      }
      
      // The stream will automatically update the UI by removing the user from pendingUsers
    } catch (e) {
      _error = 'Error al aprobar usuario: $e';
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Reject a user
  Future<void> rejectUser(String userId, BuildContext context) async {
    try {
      await _repository.rejectUser(userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario rechazado'),
            backgroundColor: Colors.orange,
          ),
        );
        await loadPendingUsers();
      }
    } catch (e) {
      _error = 'Error al rechazar usuario: $e';
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
