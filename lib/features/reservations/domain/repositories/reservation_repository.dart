/// Abstract repository interface for reservations.
///
/// Defines the contract for reservation operations.
library;

import '../entities/videobeam_entity.dart';
import '../entities/reservation_entity.dart';

abstract class ReservationRepository {
  /// Load all available videobeams
  Future<List<VideobeamEntity>> loadVideobeams();

  /// Fetch reservations for a specific date
  Future<List<ReservationEntity>> fetchReservations(DateTime date);

  /// Fetch all approved reservations
  Future<List<Map<String, dynamic>>> fetchApprovedReservations();

  /// Check for time conflicts
  Future<List<Map<String, dynamic>>> checkTimeConflicts({
    required String videobeamId,
    required DateTime date,
  });

  /// Create a new reservation via RPC
  Future<bool> createReservationViaRPC({
    required String userId,
    required String videobeamId,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Create a new reservation
  Future<bool> createReservation({
    required String userId,
    required String userName,
    required String videobeamId,
    required String videobeamName,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? department,
    String? notes,
  });

  /// Cancel a reservation
  Future<bool> cancelReservation(String reservationId);

  /// Delete a reservation
  Future<bool> deleteReservation(String reservationId);

  /// Get user's reservations
  Future<List<ReservationEntity>> getUserReservations(String userId);
}
