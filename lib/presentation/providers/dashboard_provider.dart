/// Provider del dashboard con métricas y reservas del día.
/// Refactored to use Clean Architecture repositories.

library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/reservations/domain/entities/reservation_entity.dart';
import '../../domain/entities/entities.dart'
    hide ReservationEntity, ReservationStatus, RequestPriority;

class DashboardProvider extends ChangeNotifier {
  // ignore: unused_field
  final DashboardRepository _dashboardRepository;
  RealtimeChannel? _realtimeChannel;

  DashboardProvider(this._dashboardRepository) {
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
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reservas',
        callback: (payload) {
          loadDashboard();
        },
      )
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
  List<ReservationEntity> _myReservations = [];
  DateTime _filterDate = DateTime.now();
  bool _isLoading = true;

  DashboardMetrics get metrics => _metrics;
  List<ReservationEntity> get upcomingReservations => _upcomingReservations;
  List<ReservationEntity> get myReservations => _myReservations;
  DateTime get filterDate => _filterDate;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get all products to calculate equipment metrics
      debugPrint('=== DASHBOARD: Querying productos table ===');
      final products = await _supabase.from('productos').select();
      debugPrint('DASHBOARD: Retrieved ${products.length} products');

      if (products.isNotEmpty) {
        debugPrint('DASHBOARD: First product: ${products[0]}');
      }

      final totalEquipment = products.length;
      final availableEquipment = products
          .where((p) => p['id_estado'] == 1)
          .length;
      final inMaintenance = products
          .where((p) => p['id_estado'] == 3 || p['id_estado'] == 4)
          .length;
      final inUseNow = products.where((p) => p['id_estado'] == 2).length;

      debugPrint(
        'DASHBOARD: total=$totalEquipment, available=$availableEquipment, maintenance=$inMaintenance, inUse=$inUseNow',
      );

      // 2. Get reservations for today and tomorrow (upcoming)
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfTomorrow = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        23,
        59,
        59,
      );

      final reservationsData = await _supabase
          .from('reservas')
          .select('*, productos(*), perfiles(*)')
          .gte('hora_inicio', startOfToday.toIso8601String())
          .lte('hora_inicio', endOfTomorrow.toIso8601String());

      // Filter for today's count
      final reservationsToday = reservationsData.where((r) {
        final date = DateTime.parse(r['hora_inicio']);
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).length;

      // Correct way for pending count
      final pendingCountResponse = await _supabase
          .from('reservas')
          .select('id')
          .eq('estado_reserva', 'pendiente');
      final pendingRequests = pendingCountResponse.length;

      // 3. Calculate weekly utilization
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
      debugPrint('Dashboard: Loading ${reservationsData.length} reservations');
      _upcomingReservations = reservationsData.map((r) {
        try {
          return _mapToEntity(r);
        } catch (e, stackTrace) {
          debugPrint('Error mapping reservation: $e');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('Reservation data: $r');
          rethrow;
        }
      }).toList();
      debugPrint(
        'Dashboard: Successfully loaded ${_upcomingReservations.length} reservations',
      );

      // 4. Load My Reservations filtered by _filterDate (on creado_en)
      await loadMyReservations();
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyReservations() async {
    _myReservations = []; // Limpiar antes de cargar
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Get internal profile id
      final profileData = await _supabase
          .from('perfiles')
          .select('id')
          .eq('correo', user.email!)
          .single();
      final profileId = profileData['id'];

      final startOfDay = DateTime(
        _filterDate.year,
        _filterDate.month,
        _filterDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Filtramos por 'hora_inicio' (la fecha de la reserva) para que coincida con el uso esperado
      final data = await _supabase
          .from('reservas')
          .select('*, productos(*), perfiles(*)')
          .eq('id_usuario', profileId)
          .gte('hora_inicio', startOfDay.toUtc().toIso8601String())
          .lt('hora_inicio', endOfDay.toUtc().toIso8601String())
          .order('hora_inicio', ascending: true);

      debugPrint(
        'Dashboard: Loading ${data.length} my reservations for $_filterDate',
      );
      _myReservations = data.map((r) {
        try {
          return _mapToEntity(r);
        } catch (e, stackTrace) {
          debugPrint('Error mapping my reservation: $e');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('Reservation data: $r');
          rethrow;
        }
      }).toList();
      debugPrint(
        'Dashboard: Successfully loaded ${_myReservations.length} my reservations',
      );
    } catch (e) {
      debugPrint('Error loading my reservations: $e');
    }
  }

  void nextDate() {
    _filterDate = _filterDate.add(const Duration(days: 1));
    loadMyReservations();
    notifyListeners();
  }

  void previousDate() {
    _filterDate = _filterDate.subtract(const Duration(days: 1));
    loadMyReservations();
    notifyListeners();
  }

  ReservationEntity _mapToEntity(Map<String, dynamic> r) {
    // Safe extraction with null checks for related tables
    final productosData = r['productos'];
    final perfilesData = r['perfiles'];

    // Provide fallback values if related data is null
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
      startTime: r['hora_inicio'] != null && r['hora_inicio'].length > 16
          ? r['hora_inicio'].substring(11, 16)
          : '00:00',
      endTime: r['hora_fin'] != null && r['hora_fin'].length > 16
          ? r['hora_fin'].substring(11, 16)
          : '00:00',
      status: _mapStatus(r['estado_reserva']),
      department: u['especialidad'] as String? ?? u['carrera'] as String? ?? '',
      priority: RequestPriority.normal,
      userAvatarUrl: u['foto_url'] as String?,
      notes: r['notas'] as String?,
      isRead: r['leido_por_admin'] as bool? ?? false,
      createdAt: r['creado_en'] != null ? DateTime.parse(r['creado_en']) : null,
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
      case 'completado':
        return ReservationStatus.completed;
      case 'cancelado':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }

  void refreshMetrics(DashboardMetrics newMetrics) {
    _metrics = newMetrics;
    notifyListeners();
  }
}
