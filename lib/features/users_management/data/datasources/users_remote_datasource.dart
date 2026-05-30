/// Remote data source for user management operations.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/admin_request_status_entity.dart';
import '../../domain/entities/pending_user_entity.dart';

class UsersRemoteDataSource {
  UsersRemoteDataSource(this.client);

  final SupabaseClient client;
  RealtimeChannel? _pendingApprovalsChannel;
  StreamController<List<PendingUserEntity>>? _pendingApprovalsController;

  Future<List<PendingUserEntity>> getPendingUsers() async {
    try {
      final registrationPending = await client
          .from('perfiles')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final adminPromotionPending = await client
          .from('perfiles')
          .select()
          .eq('status', 'approved')
          .eq('solicita_admin', true)
          .order('created_at', ascending: false);

      final merged = <PendingUserEntity>[
        ...(registrationPending as List).map(
          (map) => _mapToEntity(map, PendingApprovalKind.registration),
        ),
        ...(adminPromotionPending as List).map(
          (map) => _mapToEntity(map, PendingApprovalKind.adminPromotion),
        ),
      ];

      merged.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
      return merged;
    } on PostgrestException catch (error) {
      throw Exception('Failed to fetch pending users: ${error.message}');
    }
  }

  Stream<List<PendingUserEntity>> watchPendingUsers() {
    _pendingApprovalsController ??=
        StreamController<List<PendingUserEntity>>.broadcast();

    Future<void> reload() async {
      try {
        final data = await getPendingUsers();
        if (!(_pendingApprovalsController?.isClosed ?? true)) {
          _pendingApprovalsController!.add(data);
        }
      } catch (e) {
        debugPrint('[UsersDataSource] Error reloading pending: $e');
      }
    }

    reload();

    _pendingApprovalsChannel ??= client.channel('pending_user_approvals')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'perfiles',
        callback: (payload) {
          debugPrint(
            '[UsersDataSource] perfiles ${payload.eventType}, reloading',
          );
          reload();
        },
      )
      ..subscribe();

    return _pendingApprovalsController!.stream;
  }

  void disposePendingRealtime() {
    if (_pendingApprovalsChannel != null) {
      client.removeChannel(_pendingApprovalsChannel!);
      _pendingApprovalsChannel = null;
    }
    _pendingApprovalsController?.close();
    _pendingApprovalsController = null;
  }

  Future<void> approveUser(String userId) async {
    await client
        .from('perfiles')
        .update({'status': 'approved'})
        .eq('id', userId);
  }

  Future<void> rejectUser(String userId) async {
    await client
        .from('perfiles')
        .update({'status': 'rejected'})
        .eq('id', userId);
  }

  Future<void> submitAdminRequest(String userId) async {
    await client
        .from('perfiles')
        .update({'solicita_admin': true, 'solicitud_admin_rechazada': false})
        .eq('id', userId);
  }

  Future<Map<String, dynamic>> fetchProfileFlags(String userId) async {
    return await client
        .from('perfiles')
        .select('rol, solicita_admin, solicitud_admin_rechazada')
        .eq('id', userId)
        .single();
  }

  AdminRequestStatusEntity mapAdminRequestStatus(Map<String, dynamic> map) {
    final rol = map['rol'] as String? ?? 'usuario';
    final solicitaAdmin = map['solicita_admin'] as bool? ?? false;
    final rechazada = map['solicitud_admin_rechazada'] as bool? ?? false;

    if (rol == 'admin' || rol == 'super_admin') {
      return const AdminRequestStatusEntity(
        uiState: AdminRequestUiState.alreadyAdmin,
      );
    }
    if (rechazada) {
      return const AdminRequestStatusEntity(
        uiState: AdminRequestUiState.rejected,
        solicitudRechazada: true,
      );
    }
    if (solicitaAdmin) {
      return const AdminRequestStatusEntity(
        uiState: AdminRequestUiState.pending,
        solicitaAdmin: true,
      );
    }
    return const AdminRequestStatusEntity(
      uiState: AdminRequestUiState.canRequest,
    );
  }

  Future<AdminRequestStatusEntity> getAdminRequestStatus(String userId) async {
    final map = await fetchProfileFlags(userId);
    return mapAdminRequestStatus(map);
  }

  Stream<AdminRequestStatusEntity> watchAdminRequestStatus(String userId) {
    return client
        .from('perfiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) {
          if (rows.isEmpty) {
            return const AdminRequestStatusEntity(
              uiState: AdminRequestUiState.canRequest,
            );
          }
          return mapAdminRequestStatus(rows.first);
        });
  }

  Future<void> approveAdminPromotion(String userId) async {
    await client
        .from('perfiles')
        .update({
          'rol': 'admin',
          'solicita_admin': false,
          'solicitud_admin_rechazada': false,
        })
        .eq('id', userId);
  }

  Future<void> rejectAdminPromotion(String userId) async {
    await client
        .from('perfiles')
        .update({'solicita_admin': false, 'solicitud_admin_rechazada': true})
        .eq('id', userId);
  }

  PendingUserEntity _mapToEntity(
    Map<String, dynamic> map,
    PendingApprovalKind kind,
  ) {
    final primerNombre = map['primer_nombre'] as String? ?? '';
    final primerApellido = map['primer_apellido'] as String? ?? '';
    final fullName = '$primerNombre $primerApellido'.trim();

    return PendingUserEntity(
      id: map['id'] as String,
      fullName: fullName.isNotEmpty ? fullName : 'Usuario',
      email: map['correo'] as String? ?? '',
      especialidad: map['especialidad'] as String? ?? '',
      carrera: map['carrera'] as String? ?? '',
      kind: kind,
      avatarUrl: map['foto_url'] as String?,
      registeredAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
