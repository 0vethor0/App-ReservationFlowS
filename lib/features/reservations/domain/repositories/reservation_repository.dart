/// Abstract repository interface for reservations.
///
/// Defines the contract for reservation operations.
library;

import '../entities/videobeam_entity.dart';
import '../entities/reservation_entity.dart';
import '../entities/time_slot.dart';
import 'package:flutter/material.dart';

abstract class ReservationRepository {
  /// Load all videobeams (any status) for reservation UI
  Future<List<VideobeamEntity>> loadAllVideobeams();

  /// Load all available videobeams
  Future<List<VideobeamEntity>> loadVideobeams();

  /// Stream that emits when product availability changes in Supabase Realtime
  Stream<void> watchProductAvailability();

  void disposeProductRealtime();

  /// Stream that emits the occupied time slots for a product on a specific date
  Stream<List<TimeSlot>> watchReservationsForProductOnDate({
    required String productId,
    required DateTime date,
  });

  /// Check if a time slot is available for a product on a given date
  Future<bool> checkSlotAvailability({
    required String videobeamId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  });

  /// Fetch reservations for a specific date
  Future<List<ReservationEntity>> fetchReservations(DateTime date);

  /// Fetch all approved reservations
  Future<List<Map<String, dynamic>>> fetchApprovedReservations();

  /// Approved reservations for a product on a given day (conflict check)
  Future<List<Map<String, dynamic>>> fetchApprovedReservationsForProductOnDate({
    required String videobeamId,
    required DateTime date,
  });

  Future<String> getProfileIdByEmail(String email);

  /// Create a new reservation via RPC
  Future<bool> createReservationViaRPC({
    required String userId,
    required String videobeamId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });

  /// Create multiple reservations via RPC
  Future<bool> createMultipleReservations({
    required String userId,
    required String productId,
    required List<Map<String, dynamic>> dates,
    String? globalNotes,
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
