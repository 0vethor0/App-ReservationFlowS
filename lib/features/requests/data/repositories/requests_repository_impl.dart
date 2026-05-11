/// Implementation of RequestsRepository.
library;

import '../../domain/repositories/requests_repository.dart';
import '../../../reservations/domain/entities/reservation_entity.dart';
import '../datasources/requests_remote_datasource.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  final RequestsRemoteDataSource remoteDataSource;

  RequestsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ReservationEntity>> loadPendingRequests() async {
    final data = await remoteDataSource.loadPendingRequests();

    return data.map((item) => _mapToReservationEntity(item)).toList();
  }

  @override
  Future<List<ReservationEntity>> loadAllRequests() async {
    final data = await remoteDataSource.loadAllRequests();

    return data.map((item) => _mapToReservationEntity(item)).toList();
  }

  @override
  Future<bool> updateRequestStatus({
    required String requestId,
    required ReservationStatus status,
  }) async {
    try {
      await remoteDataSource.updateRequestStatus(
        requestId: requestId,
        status: _mapStatusToString(status),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markAsRead(String requestId) async {
    try {
      await remoteDataSource.markAsRead(requestId);
      return true;
    } catch (e) {
      return false;
    }
  }

  ReservationEntity _mapToReservationEntity(Map<String, dynamic> item) {
    return ReservationEntity(
      id: item['id']?.toString() ?? 'unknown',
      userId: item['usuario_id'] ?? '',
      userName: item['usuario_nombre'] ?? '',
      videobeamId: item['videobeam_id'] ?? '',
      videobeamName: item['videobeam_nombre'] ?? '',
      date: DateTime.parse(item['fecha']),
      startTime: item['hora_inicio'] ?? '',
      endTime: item['hora_fin'] ?? '',
      status: _mapStatus(item['estado']),
    );
  }

  ReservationStatus _mapStatus(String? status) {
    switch (status) {
      case 'approved':
        return ReservationStatus.approved;
      case 'rejected':
        return ReservationStatus.rejected;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }

  String _mapStatusToString(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.approved:
        return 'approved';
      case ReservationStatus.rejected:
        return 'rejected';
      case ReservationStatus.completed:
        return 'completed';
      case ReservationStatus.cancelled:
        return 'cancelled';
      default:
        return 'pending';
    }
  }
}
