/// Abstract repository interface for requests.
///
/// Defines the contract for request management operations.
library;

import '../../../reservations/domain/entities/reservation_entity.dart';

abstract class RequestsRepository {
  /// Load all pending requests (for admins)
  Future<List<ReservationEntity>> loadPendingRequests();

  /// Load all requests
  Future<List<ReservationEntity>> loadAllRequests();

  /// Update request status
  Future<bool> updateRequestStatus({
    required String requestId,
    required ReservationStatus status,
  });

  /// Mark request as read
  Future<bool> markAsRead(String requestId);
}
