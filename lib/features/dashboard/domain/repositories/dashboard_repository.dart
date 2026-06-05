/// Abstract repository interface for dashboard.
///
/// Defines the contract for dashboard data operations.
library;

import '../entities/dashboard_metrics_entity.dart';
import '../../../reservations/domain/entities/reservation_entity.dart';

// ignore: avoid_using_map_from
abstract class DashboardRepository {
  /// Load dashboard metrics
  Future<DashboardMetrics> loadDashboardMetrics();

  /// Load upcoming reservations
  Future<List<ReservationEntity>> loadUpcomingReservations();

  /// Load user's reservations
  Future<List<ReservationEntity>> loadMyReservations(DateTime date);

  /// Subscribe to realtime updates for reservations
  Stream<List<Map<String, dynamic>>> subscribeToReservationsRealtime();

  /// Update reservation status
  Future<void> updateReservationStatus(String id, String status);

  /// Emits when product availability changes (liberación automática o admin)
  Stream<void> watchProductAvailability();

  /// Dispose realtime subscriptions
  void disposeRealtime();
}
