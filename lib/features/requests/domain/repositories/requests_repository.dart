library;

import '../../../reservations/domain/entities/reservation_entity.dart';

abstract class RequestsRepository {
  Future<List<ReservationEntity>> loadPendingRequests();

  Future<List<ReservationEntity>> loadAllRequests();

  Stream<List<ReservationEntity>> streamAllRequests();

  Stream<List<ReservationEntity>> streamPendingRequests();

  Future<bool> updateRequestStatus({
    required String requestId,
    required ReservationStatus status,
  });

  Future<bool> markAsRead(String requestId);
}