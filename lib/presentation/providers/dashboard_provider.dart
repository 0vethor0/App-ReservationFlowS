/// Provider del dashboard con métricas y reservas del día.
library;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/entities.dart';

class DashboardProvider extends ChangeNotifier {
  RealtimeChannel? _realtimeChannel;

  DashboardProvider() {
    loadDashboard();
    _setupRealtime();
  }

  void _setupRealtime() {
    _realtimeChannel = _supabase.channel('dashboard_metrics')
      ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'productos',
          callback: (payload) {
            loadDashboard();
          })
      ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reservas',
          callback: (payload) {
            loadDashboard();
          })
      ..subscribe();
  }

  @override
  void dispose() {
    if (_realtimeChannel != null) {
      _supabase.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  DashboardMetrics _metrics = const DashboardMetrics();
  List<ReservationEntity> _upcomingReservations = [];
  bool _isLoading = true;

  DashboardMetrics get metrics => _metrics;
  List<ReservationEntity> get upcomingReservations => _upcomingReservations;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get all products to calculate equipment metrics
      final products = await _supabase.from('productos').select();
      final totalEquipment = products.length;
      final availableEquipment = products.where((p) => p['id_estado'] == 1).length;
      final inMaintenance = products.where((p) => p['id_estado'] == 3 || p['id_estado'] == 4).length;
      final inUseNow = products.where((p) => p['id_estado'] == 2).length;

      // 2. Get reservations for today and tomorrow (upcoming)
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);

      final reservationsData = await _supabase
          .from('reservas')
          .select('*, productos(*), perfiles(*)')
          .gte('hora_inicio', startOfToday.toIso8601String())
          .lte('hora_inicio', endOfTomorrow.toIso8601String());

      // Filter for today's count
      final reservationsToday = reservationsData.where((r) {
        final date = DateTime.parse(r['hora_inicio']);
        return date.year == now.year && date.month == now.month && date.day == now.day;
      }).length;


      
      // Correct way for pending count
      final pendingCountResponse = await _supabase
          .from('reservas')
          .select('id')
          .eq('estado_reserva', 'pendiente');
      final pendingRequests = pendingCountResponse.length;

      // 3. Calculate weekly utilization (mocking the logic since it needs aggregation)
      // In a real app, this would be a Supabase RPC
      final weeklyUtilization = [72.0, 65.0, 45.0, 88.0, 92.0, 30.0, 18.0];

      _metrics = DashboardMetrics(
        reservationsToday: reservationsToday,
        availableEquipment: availableEquipment,
        totalEquipment: totalEquipment,
        inMaintenance: inMaintenance,
        inUseNow: inUseNow,
        pendingRequests: pendingRequests,
        weeklyUtilization: weeklyUtilization,
      );

      // Map to entities for upcoming reservations
      _upcomingReservations = reservationsData.map((r) {
        final p = r['productos'] as Map<String, dynamic>;
        final u = r['perfiles'] as Map<String, dynamic>;
        return ReservationEntity(
          id: r['id'].toString(),
          userId: u['id'].toString(),
          userName: '${u['primer_nombre']} ${u['primer_apellido'] ?? ''}',
          videobeamId: p['id'].toString(),
          videobeamName: p['nombre'] as String,
          location: p['ubicacion'] as String,
          date: DateTime.parse(r['hora_inicio']),
          startTime: r['hora_inicio'].substring(11, 16),
          endTime: r['hora_fin'].substring(11, 16),
          status: _mapStatus(r['estado_reserva']),
          department: u['carrera'] as String? ?? '',
          priority: RequestPriority.normal, // Not explicitly in schema, defaulting
          userAvatarUrl: u['foto_url'],
        );
      }).toList();

    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  ReservationStatus _mapStatus(String status) {
    switch (status) {
      case 'aprobado': return ReservationStatus.approved;
      case 'rechazado': return ReservationStatus.rejected;
      case 'completado': return ReservationStatus.completed;
      case 'cancelado': return ReservationStatus.cancelled;
      default: return ReservationStatus.pending;
    }
  }

  void refreshMetrics(DashboardMetrics newMetrics) {
    _metrics = newMetrics;
    notifyListeners();
  }
}
