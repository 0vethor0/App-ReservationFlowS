/// Implementation of IUserManagementRepository.
///
/// Connects UsersRemoteDataSource to domain layer.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/pending_user_entity.dart';
import '../../domain/repositories/i_user_management_repository.dart';
import '../datasources/users_remote_datasource.dart';

class UserManagementRepositoryImpl implements IUserManagementRepository {
  final UsersRemoteDataSource remoteDataSource;

  UserManagementRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PendingUserEntity>> getPendingUsers() async {
    try {
      return await remoteDataSource.getPendingUsers();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener usuarios pendientes: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> approveUser(String userId) async {
    try {
      await remoteDataSource.approveUser(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al aprobar usuario: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> rejectUser(String userId) async {
    try {
      await remoteDataSource.rejectUser(userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al rechazar usuario: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Stream<List<PendingUserEntity>> watchPendingUsers() {
    return remoteDataSource.watchPendingUsers();
  }
}
