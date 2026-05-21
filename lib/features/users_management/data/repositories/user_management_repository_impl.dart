/// Implementation of IUserManagementRepository.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/admin_request_status_entity.dart';
import '../../domain/entities/pending_user_entity.dart';
import '../../domain/repositories/i_user_management_repository.dart';
import '../datasources/users_remote_datasource.dart';

class UserManagementRepositoryImpl implements IUserManagementRepository {
  UserManagementRepositoryImpl(this.remoteDataSource);

  final UsersRemoteDataSource remoteDataSource;

  @override
  Future<List<PendingUserEntity>> getPendingUsers() async {
    try {
      return await remoteDataSource.getPendingUsers();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener solicitudes pendientes: ${e.message}');
    }
  }

  @override
  Future<void> approveUser(String userId) async {
    try {
      await remoteDataSource.approveUser(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al aprobar usuario: ${e.message}');
    }
  }

  @override
  Future<void> rejectUser(String userId) async {
    try {
      await remoteDataSource.rejectUser(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al rechazar usuario: ${e.message}');
    }
  }

  @override
  Stream<List<PendingUserEntity>> watchPendingUsers() {
    return remoteDataSource.watchPendingUsers();
  }

  @override
  Future<void> submitAdminRequest(String userId) async {
    try {
      await remoteDataSource.submitAdminRequest(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al enviar solicitud de admin: ${e.message}');
    }
  }

  @override
  Future<AdminRequestStatusEntity> getAdminRequestStatus(String userId) async {
    try {
      return await remoteDataSource.getAdminRequestStatus(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener estado de solicitud: ${e.message}');
    }
  }

  @override
  Stream<AdminRequestStatusEntity> watchAdminRequestStatus(String userId) {
    return remoteDataSource.watchAdminRequestStatus(userId);
  }

  @override
  Future<void> approveAdminPromotion(String userId) async {
    try {
      await remoteDataSource.approveAdminPromotion(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al aprobar promoción admin: ${e.message}');
    }
  }

  @override
  Future<void> rejectAdminPromotion(String userId) async {
    try {
      await remoteDataSource.rejectAdminPromotion(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al rechazar promoción admin: ${e.message}');
    }
  }

  @override
  void disposeRealtime() {
    remoteDataSource.disposePendingRealtime();
  }
}
