/// Provider del dashboard con métricas y reservas del día.
import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider() {
    loadDashboard();
  }

  DashboardMetrics _metrics = const DashboardMetrics();
  List<ReservationEntity> _upcomingReservations = [];
  bool _isLoading = true;

  DashboardMetrics get metrics => _metrics;
  List<ReservationEntity> get upcomingReservations => _upcomingReservations;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    // Simulated data — replace with Supabase queries in production
    await Future<void>.delayed(const Duration(milliseconds: 800));

    _metrics = const DashboardMetrics(
      reservationsToday: 12,
      availableEquipment: 28,
      totalEquipment: 45,
      inMaintenance: 3,
      inUseNow: 14,
      pendingRequests: 5,
      weeklyUtilization: [72, 65, 45, 88, 92, 30, 18],
    );

    _upcomingReservations = [
      ReservationEntity(
        id: '1',
        userId: 'u1',
        userName: 'Carlos Mendoza',
        videobeamId: 'v1',
        videobeamName: 'Epson Pro EX9220',
        location: 'Sala de Juntas A',
        date: DateTime.now(),
        startTime: '14:30',
        endTime: '16:00',
        department: 'Marketing',
        status: ReservationStatus.approved,
      ),
      ReservationEntity(
        id: '2',
        userId: 'u2',
        userName: 'Ana Silva',
        videobeamId: 'v2',
        videobeamName: 'Sony VPL-PHZ60',
        location: 'Auditorio Principal',
        date: DateTime.now(),
        startTime: '16:00',
        endTime: '18:00',
        department: 'Ventas',
        status: ReservationStatus.approved,
      ),
      ReservationEntity(
        id: '3',
        userId: 'u3',
        userName: 'Luis Torres',
        videobeamId: 'v3',
        videobeamName: 'BenQ TH685P',
        location: 'Sala Capacitación',
        date: DateTime.now().add(const Duration(days: 1)),
        startTime: '09:00',
        endTime: '11:00',
        department: 'Recursos Humanos',
        status: ReservationStatus.pending,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void refreshMetrics(DashboardMetrics newMetrics) {
    _metrics = newMetrics;
    notifyListeners();
  }
}
