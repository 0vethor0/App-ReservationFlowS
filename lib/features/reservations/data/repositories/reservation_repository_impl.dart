/// Implementation of ReservationRepository.
library;

import '../../domain/repositories/reservation_repository.dart';
import '../../domain/entities/videobeam_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../datasources/reservation_remote_datasource.dart';
import 'dart:developer' as developer;

class ReservationRepositoryImpl implements ReservationRepository {
  ReservationRepositoryImpl(this.remoteDataSource);

  final ReservationRemoteDataSource remoteDataSource;

  @override
  Future<List<VideobeamEntity>> loadAllVideobeams() async {
    final data = await remoteDataSource.loadAllVideobeams();
    return data.map(_mapToVideobeamEntity).toList();
  }

  @override
  Future<List<VideobeamEntity>> loadVideobeams() async {
    final data = await remoteDataSource.loadVideobeams();
    return data.map(_mapToVideobeamEntity).toList();
  }

  @override
  Stream<void> watchProductAvailability() {
    return remoteDataSource.watchProductAvailability();
  }

  @override
  void disposeProductRealtime() {
    remoteDataSource.disposeProductRealtime();
  }

  @override
  Future<List<ReservationEntity>> fetchReservations(DateTime date) async {
    final data = await remoteDataSource.fetchReservations(date);
    return data.map(_mapToReservationEntity).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchApprovedReservations() async {
    return remoteDataSource.fetchApprovedReservations();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchApprovedReservationsForProductOnDate({
    required String videobeamId,
    required DateTime date,
  }) async {
    return remoteDataSource.fetchApprovedReservationsForProductOnDate(
      productId: videobeamId,
      date: date,
    );
  }

  @override
  Future<String> getProfileIdByEmail(String email) async {
    return remoteDataSource.getProfileIdByEmail(email);
  }

  @override
  Future<bool> createReservationViaRPC({
    required String userId,
    required String videobeamId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      await remoteDataSource.createReservationViaRpc(
        userId: userId,
        productId: videobeamId,
        start: startTime,
        end: endTime,
        notes: notes,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> createMultipleReservations({
    required String userId,
    required String productId,
    required List<Map<String, dynamic>> dates,
    String? globalNotes,
  }) async {
    try {
      final response = await remoteDataSource.createMultipleReservationsViaRpc(
        userId: userId,
        productId: productId,
        dates: dates,
        globalNotes: globalNotes,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        developer.log(
          '[ReservationRepositoryImpl] Error desde RPC: ${response['message']}',
        );
      }
      return success;
    } catch (e) {
      developer.log('[ReservationRepositoryImpl] Excepción al llamar RPC: $e');
      return false;
    }
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
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> cancelReservation(String reservationId) async {
    try {
      await remoteDataSource.cancelReservation(reservationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteReservation(String reservationId) async {
    try {
      await remoteDataSource.deleteReservation(reservationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ReservationEntity>> getUserReservations(String userId) async {
    final data = await remoteDataSource.getUserReservations(userId);
    return data.map(_mapToReservationEntity).toList();
  }

  VideobeamEntity _mapToVideobeamEntity(Map<String, dynamic> item) {
    final idEstado = item['id_estado'] as int?;
    final status = switch (idEstado) {
      1 => VideobeamStatus.available,
      2 => VideobeamStatus.inUse,
      3 || 4 => VideobeamStatus.maintenance,
      _ => VideobeamStatus.available,
    };

    return VideobeamEntity(
      id: item['id']?.toString() ?? 'unknown',
      name: item['nombre'] as String? ?? 'Videobeam',
      brand: item['marca'] as String? ?? '',
      model: item['modelo'] as String? ?? '',
      status: status,
    );
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
