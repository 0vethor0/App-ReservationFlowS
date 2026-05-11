/// Implementation of ReservationRepository.
library;

import '../../domain/repositories/reservation_repository.dart';
import '../../domain/entities/videobeam_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../datasources/reservation_remote_datasource.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  ReservationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<VideobeamEntity>> loadVideobeams() async {
    final data = await remoteDataSource.loadVideobeams();

    return data.map((item) {
      return VideobeamEntity(
        id: item['id']?.toString() ?? 'unknown',
        name: item['nombre'] as String? ?? 'Videobeam',
        brand: item['marca'] as String? ?? '',
        model: item['modelo'] as String? ?? '',
        status: VideobeamStatus.available,
      );
    }).toList();
  }

  @override
  Future<List<ReservationEntity>> fetchReservations(DateTime date) async {
    final data = await remoteDataSource.fetchReservations(date);

    return data.map((item) => _mapToReservationEntity(item)).toList();
  }

  @override
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
  }) async {
    try {
      await remoteDataSource.createReservation({
        'usuario_id': userId,
        'usuario_nombre': userName,
        'videobeam_id': videobeamId,
        'videobeam_nombre': videobeamName,
        'fecha': date.toIso8601String().split('T').first,
        'hora_inicio': startTime,
        'hora_fin': endTime,
        'departamento': department,
        'notas': notes,
        'estado': 'pending',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> cancelReservation(String reservationId) async {
    try {
      await remoteDataSource.cancelReservation(reservationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ReservationEntity>> getUserReservations(String userId) async {
    final data = await remoteDataSource.getUserReservations(userId);

    return data.map((item) => _mapToReservationEntity(item)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchApprovedReservations() async {
    // This would need to be added to the datasource
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> checkTimeConflicts({
    required String videobeamId,
    required DateTime date,
  }) async {
    // This would need to be added to the datasource
    return [];
  }

  @override
  Future<bool> createReservationViaRPC({
    required String userId,
    required String videobeamId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // RPC calls need special handling - return false for now
    return false;
  }

  @override
  Future<bool> deleteReservation(String reservationId) async {
    try {
      // This would need to be added to the datasource
      return false;
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
      department: item['departamento'],
      notes: item['notas'],
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
}
