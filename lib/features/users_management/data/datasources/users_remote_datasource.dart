/// Remote data source for user management operations.
///
/// Handles Supabase calls for admin user approval workflows.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/pending_user_entity.dart';

class UsersRemoteDataSource {
  final SupabaseClient client;

  UsersRemoteDataSource(this.client);

  /// Get list of pending users (one-shot query)
  Future<List<PendingUserEntity>> getPendingUsers() async {
    try {
      final response = await client
          .from('perfiles')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

          return (response as List).map((map) => _mapToEntity(map)).toList();

    } on PostgrestException catch (error) {
      throw Exception('Failed to fetch pending users: ${error.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }

    }

  /// Watch pending users in real-time using Supabase streams
  Stream<List<PendingUserEntity>> watchPendingUsers() {
    return client
        .from('perfiles')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => _mapToEntity(map)).toList());
  }

  /// Approve a user by updating their status to 'approved'
  Future<void> approveUser(String userId) async {
    try {
      await client
          .from('perfiles')
          .update({'status': 'approved'})
          .eq('id', userId)
          .select('id, status');
    } on PostgrestException catch (error) {
      throw Exception('Failed to approve user: ${error.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Reject a user by updating their status to 'rejected'
  Future<void> rejectUser(String userId) async {
    try {
      await client
          .from('perfiles')
          .update({'status': 'rejected'})
          .eq('id', userId);
    } on PostgrestException catch (error) {
      throw Exception('Failed to reject user: ${error.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  

  /// Map database record to PendingUserEntity
  PendingUserEntity _mapToEntity(Map<String, dynamic> map) {
    final primerNombre = map['primer_nombre'] as String? ?? '';
    final primerApellido = map['primer_apellido'] as String? ?? '';
    final fullName = '$primerNombre $primerApellido'.trim();

    return PendingUserEntity(
      id: map['id'] as String,
      fullName: fullName.isNotEmpty ? fullName : 'Usuario',
      email: map['correo'] as String? ?? '',
      especialidad: map['especialidad'] as String? ?? '',
      carrera: map['carrera'] as String? ?? '',
      avatarUrl: map['foto_url'] as String?,
      registeredAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
