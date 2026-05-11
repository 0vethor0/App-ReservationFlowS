/// Abstract repository interface for dashboard.
///
/// Defines the contract for dashboard data operations.
library;

import '../entities/dashboard_metrics_entity.dart';
import '../../../reservations/domain/entities/reservation_entity.dart';

abstract class DashboardRepository {
  /// Load dashboard metrics
  Future<DashboardMetrics> loadDashboardMetrics();

  /// Load upcoming reservations
  Future<List<ReservationEntity>> loadUpcomingReservations();

  /// Load user's reservations
  Future<List<ReservationEntity>> loadMyReservations(String userId);

  /// Subscribe to realtime updates
  void subscribeToRealtimeUpdates();

  /// Dispose realtime subscriptions
  void disposeRealtime();
}
