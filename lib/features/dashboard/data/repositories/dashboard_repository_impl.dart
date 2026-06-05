/// Implementation of DashboardRepository.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_metrics_entity.dart';
import '../../../reservations/domain/entities/reservation_entity.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this.remoteDataSource, this.client);

  final DashboardRemoteDataSource remoteDataSource;
  // ignore: unused_field
  final SupabaseClient client;

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

    return data.map(_mapToReservationEntity).toList();
  }

  @override
  Future<List<ReservationEntity>> loadMyReservations(DateTime date) async {
    final user = client.auth.currentUser;
    if (user == null || user.email == null) return [];

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final data = await remoteDataSource.getMyReservations(
      email: user.email!,
      startDate: startOfDay.toUtc().toIso8601String(),
      endDate: endOfDay.toUtc().toIso8601String(),
    );

    return data.map(_mapToReservationEntity).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> subscribeToReservationsRealtime() {
    return remoteDataSource.subscribeToReservasRealtime();
  }

  @override
  Future<void> updateReservationStatus(String id, String status) async {
    await remoteDataSource.updateReservationStatus(id, status);
  }

  @override
  Stream<void> watchProductAvailability() {
    return remoteDataSource.watchProductAvailability();
  }

  @override
  void disposeRealtime() {
    remoteDataSource.disposeProductRealtime();
  }

  ReservationEntity _mapToReservationEntity(Map<String, dynamic> r) {
    final productosData = r['productos'];
    final perfilesData = r['perfiles'];

    final p = productosData is Map<String, dynamic>
        ? productosData
        : <String, dynamic>{};
    final u = perfilesData is Map<String, dynamic>
        ? perfilesData
        : <String, dynamic>{};

    return ReservationEntity(
      id: r['id']?.toString() ?? 'unknown',
      userId: u['id']?.toString() ?? 'unknown',
      userName:
          '${u['primer_nombre'] ?? 'Usuario'} ${u['primer_apellido'] ?? ''}',
      videobeamId: p['id']?.toString() ?? 'unknown',
      videobeamName: p['nombre'] as String? ?? 'Videobeam',
      date: r['hora_inicio'] != null
          ? DateTime.parse(r['hora_inicio'])
          : DateTime.now(),
      startTime: r['hora_inicio'] != null
          ? "${DateTime.parse(r['hora_inicio']).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(r['hora_inicio']).toLocal().minute.toString().padLeft(2, '0')}"
          : '00:00',
      endTime: r['hora_fin'] != null
          ? "${DateTime.parse(r['hora_fin']).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(r['hora_fin']).toLocal().minute.toString().padLeft(2, '0')}"
          : '00:00',
      status: _mapStatus(r['estado_reserva']),
      department: u['especialidad'] as String? ?? u['carrera'] as String? ?? '',
      priority: r['prioridad'] == 'alta'
          ? RequestPriority.high
          : RequestPriority.normal,
      userAvatarUrl: u['foto_url'] as String?,
      notes: r['notas'] as String?,
      isRead: r['leido_por_admin'] as bool? ?? false,
      createdAt: r['creado_en'] != null
          ? DateTime.parse(r['creado_en']).toLocal()
          : null,
    );
  }

  ReservationStatus _mapStatus(String? status) {
    if (status == null) return ReservationStatus.pending;
    switch (status.toLowerCase()) {
      case 'aprobado':
      case 'aprobada':
        return ReservationStatus.approved;
      case 'rechazado':
      case 'rechazada':
      case 'desaprobado':
        return ReservationStatus.rejected;
      case 'en_curso':
        return ReservationStatus.inProgress;
      case 'completado':
      case 'finalizada':
        return ReservationStatus.completed;
      case 'cancelado':
      case 'cancelada':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }
}
