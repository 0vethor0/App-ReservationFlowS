/// Implementation of DashboardRepository.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_metrics_entity.dart';
import '../../../reservations/domain/entities/reservation_entity.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  RealtimeChannel? _realtimeChannel;
  final SupabaseClient client;

  DashboardRepositoryImpl(this.remoteDataSource, this.client);

  @override
  Future<DashboardMetrics> loadDashboardMetrics() async {
    final products = await remoteDataSource.getProducts();

    final totalEquipment = products.length;
    final availableEquipment = products
        .where((p) => p['id_estado'] == 1)
        .length;
    final inMaintenance = products
        .where((p) => p['id_estado'] == 3 || p['id_estado'] == 4)
        .length;
    final inUseNow = products.where((p) => p['id_estado'] == 2).length;

    final reservationsToday = await remoteDataSource
        .getTodayReservationsCount();
    final pendingRequests = await remoteDataSource.getPendingRequestsCount();

    return DashboardMetrics(
      reservationsToday: reservationsToday,
      availableEquipment: availableEquipment,
      totalEquipment: totalEquipment,
      inMaintenance: inMaintenance,
      inUseNow: inUseNow,
      pendingRequests: pendingRequests,
    );
  }

  @override
  Future<List<ReservationEntity>> loadUpcomingReservations() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    final data = await remoteDataSource.getReservationsInRange(
      startDate: now.toIso8601String(),
      endDate: tomorrow.toIso8601String(),
    );

    return data.map((item) => _mapToReservationEntity(item)).toList();
  }

  @override
  Future<List<ReservationEntity>> loadMyReservations(String userId) async {
    // Implementation would filter by userId
    return [];
  }

  @override
  void subscribeToRealtimeUpdates() {
    _realtimeChannel = client.channel('dashboard_metrics')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'productos',
        callback: (payload) {
          // Notify listeners to reload
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reservas',
        callback: (payload) {
          // Notify listeners to reload
        },
      )
      ..subscribe();
  }

  @override
  void disposeRealtime() {
    if (_realtimeChannel != null) {
      client.removeChannel(_realtimeChannel!);
    }
  }

  ReservationEntity _mapToReservationEntity(Map<String, dynamic> item) {
    return ReservationEntity(
      id: item['id']?.toString() ?? 'unknown',
      userId: item['usuario_id'] ?? '',
      userName: item['usuario_nombre'] ?? '',
      videobeamId: item['videobeam_id'] ?? '',
      videobeamName: item['videobeam_nombre'] ?? '',
      date: DateTime.parse(item['fecha']),
      startTime: item['hora_inicio'] ?? '',
      endTime: item['hora_fin'] ?? '',
      status: _mapStatus(item['estado']),
    );
  }

  ReservationStatus _mapStatus(String? status) {
    switch (status) {
      case 'approved':
        return ReservationStatus.approved;
      case 'rejected':
        return ReservationStatus.rejected;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }
}
