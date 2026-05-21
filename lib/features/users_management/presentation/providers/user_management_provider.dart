/// Provider for user management operations.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import '../../domain/entities/pending_user_entity.dart';
import '../../domain/repositories/i_user_management_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  UserManagementProvider(this._repository) {
    _init();
  }

  final IUserManagementRepository _repository;
  List<PendingUserEntity> _pendingUsers = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<PendingUserEntity>>? _subscription;

  List<PendingUserEntity> get pendingUsers => _pendingUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    _subscription = _repository.watchPendingUsers().listen(
      (users) {
        _pendingUsers = users;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = 'Error al cargar solicitudes: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadPendingUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingUsers = await _repository.getPendingUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar solicitudes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveUser(String userId, BuildContext context) async {
    await _handleAction(
      context: context,
      action: () => _repository.approveUser(userId),
      successMessage: 'Usuario aprobado exitosamente',
    );
  }

  Future<void> rejectUser(String userId, BuildContext context) async {
    await _handleAction(
      context: context,
      action: () => _repository.rejectUser(userId),
      successMessage: 'Registro rechazado',
      successColor: Colors.orange,
    );
  }

  Future<void> approveAdminPromotion(String userId, BuildContext context) async {
    await _handleAction(
      context: context,
      action: () => _repository.approveAdminPromotion(userId),
      successMessage: 'Usuario promovido a admin',
    );
  }

  Future<void> rejectAdminPromotion(String userId, BuildContext context) async {
    await _handleAction(
      context: context,
      action: () => _repository.rejectAdminPromotion(userId),
      successMessage: 'Solicitud de admin denegada',
      successColor: Colors.orange,
    );
  }

  Future<void> _handleAction({
    required BuildContext context,
    required Future<void> Function() action,
    required String successMessage,
    Color successColor = Colors.green,
  }) async {
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: successColor,
          ),
        );
        await loadPendingUsers();
      }
    } catch (e) {
      _error = 'Error: $e';
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
    _repository.disposeRealtime();
    super.dispose();
  }
}
