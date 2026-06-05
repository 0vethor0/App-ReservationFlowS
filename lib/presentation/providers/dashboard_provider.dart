/// Provider del dashboard con métricas y reservas del día.
/// Refactored to use Clean Architecture repositories.

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/reservations/domain/entities/reservation_entity.dart';
import '../../features/dashboard/domain/entities/dashboard_metrics_entity.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  StreamSubscription? _realtimeSubscription;
  StreamSubscription? _productAvailabilitySubscription;
  final Set<String> _shownInsertIds = {};

  // Callback for new reservation notifications
  Function(Map<String, dynamic> newReservation)? onNewReservation;

  // Separate loading state for my reservations
  bool _isLoadingMyReservations = false;

  DashboardProvider(this._dashboardRepository) {
    loadDashboard();
    _setupRealtime();
  }

  void _setupRealtime() {
    _realtimeSubscription = _dashboardRepository
        .subscribeToReservationsRealtime()
        .listen((data) {
          for (final r in data) {
            final id = r['id'].toString();
            final eventType = r['@eventType'] as String?;

            if (eventType == 'INSERT' && !_shownInsertIds.contains(id)) {
              _shownInsertIds.add(id);
              onNewReservation?.call(r);
            }
          }

          loadMyReservations();
        });

    _productAvailabilitySubscription = _dashboardRepository
        .watchProductAvailability()
        .listen((_) {
          debugPrint(
            '[DashboardProvider] Disponibilidad de productos actualizada',
          );
          loadDashboard();
        });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _productAvailabilitySubscription?.cancel();
    _dashboardRepository.disposeRealtime();
    super.dispose();
  }

  DashboardMetrics _metrics = const DashboardMetrics();
  List<ReservationEntity> _upcomingReservations = [];
  List<ReservationEntity> _myReservations = [];
  String _myReservationsFilter = 'Aprobadas';
  DateTime _filterDate = DateTime.now();
  bool _isLoading = true;

  DashboardMetrics get metrics => _metrics;
  List<ReservationEntity> get upcomingReservations => _upcomingReservations;
  List<ReservationEntity> get myReservations => _myReservations;

  String get myReservationsFilter => _myReservationsFilter;

  List<ReservationEntity> get filteredMyReservations {
    return _myReservations.where((r) {
      switch (_myReservationsFilter) {
        case 'Pendientes':
          return r.status == ReservationStatus.pending;
        case 'Aprobadas':
          return r.status == ReservationStatus.approved;
        case 'En curso':
          return r.status == ReservationStatus.inProgress;
        case 'Canceladas':
          return r.status == ReservationStatus.cancelled;
        case 'Finalizadas':
          return r.status == ReservationStatus.completed;
        case 'Rechazadas':
          return r.status == ReservationStatus.rejected;
        default:
          return true;
      }
    }).toList();
  }

  DateTime get filterDate => _filterDate;
  bool get isLoading => _isLoading;
  bool get isLoadingMyReservations => _isLoadingMyReservations;
  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _metrics = await _dashboardRepository.loadDashboardMetrics();
      _upcomingReservations = await _dashboardRepository
          .loadUpcomingReservations();

      // Load My Reservations filtered by _filterDate
      await loadMyReservations();
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyReservations() async {
    _isLoadingMyReservations = true;
    _myReservations = []; // Limpiar antes de cargar
    notifyListeners();

    try {
      _myReservations = await _dashboardRepository.loadMyReservations(
        _filterDate,
      );
      debugPrint(
        'Dashboard: Successfully loaded ${_myReservations.length} my reservations',
      );
    } catch (e) {
      debugPrint('Error loading my reservations: $e');
    } finally {
      _isLoadingMyReservations = false;
      notifyListeners();
    }
  }

  void setFilterDate(DateTime date) {
    _filterDate = date;
    notifyListeners();
    loadMyReservations();
  }

  void nextDate() {
    _filterDate = _filterDate.add(const Duration(days: 1));
    // Don't call loadMyReservations here - let the UI trigger it via the loading state
    notifyListeners();
    // Load reservations for the new date
    loadMyReservations();
  }

  void previousDate() {
    _filterDate = _filterDate.subtract(const Duration(days: 1));
    // Don't call loadMyReservations here - let the UI trigger it via the loading state
    notifyListeners();
    // Load reservations for the new date
    loadMyReservations();
  }

  void setMyReservationsFilter(String filter) {
    _myReservationsFilter = filter;
    notifyListeners();
  }

  Future<void> cancelMyReservation(String id) async {
    try {
      debugPrint('[DashboardProvider] Cancelling my reservation: $id');
      await _dashboardRepository.updateReservationStatus(id, 'cancelada');
      debugPrint('[DashboardProvider] Reservation cancelled successfully');
    } catch (e) {
      debugPrint('[DashboardProvider] Error cancelling my reservation: $e');
    }
  }

  Future<void> completeMyReservation(String id) async {
    try {
      debugPrint('[DashboardProvider] Completing my reservation: $id');
      await _dashboardRepository.updateReservationStatus(id, 'finalizada');
      debugPrint('[DashboardProvider] Reservation completed successfully');
    } catch (e) {
      debugPrint('[DashboardProvider] Error completing my reservation: $e');
    }
  }

  void refreshMetrics(DashboardMetrics newMetrics) {
    _metrics = newMetrics;
    notifyListeners();
  }
}
