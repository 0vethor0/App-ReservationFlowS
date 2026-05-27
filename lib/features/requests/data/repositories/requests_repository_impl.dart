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
  Stream<List<ReservationEntity>> streamAllRequests() {
    return remoteDataSource.streamAllRequests().map((data) {
      return data.map((item) => _mapToReservationEntity(item)).toList();
    });
  }

  @override
  Stream<List<ReservationEntity>> streamPendingRequests() {
    return remoteDataSource.streamPendingRequests().map((data) {
      return data.map((item) => _mapToReservationEntity(item)).toList();
    });
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
    final productosData = item['productos'];
    final perfilesData = item['perfiles'];

    final p = productosData is Map<String, dynamic>
        ? productosData
        : <String, dynamic>{};
    final u = perfilesData is Map<String, dynamic>
        ? perfilesData
        : <String, dynamic>{};

    return ReservationEntity(
      id: item['id']?.toString() ?? 'unknown',
      userId: u['id']?.toString() ?? 'unknown',
      userName:
          '${u['primer_nombre'] ?? 'Usuario'} ${u['primer_apellido'] ?? ''}',
      videobeamId: p['id']?.toString() ?? 'unknown',
      videobeamName: p['nombre'] as String? ?? 'Videobeam',
      date: item['hora_inicio'] != null
          ? DateTime.parse(item['hora_inicio'])
          : DateTime.now(),
      startTime: item['hora_inicio'] != null
          ? "${DateTime.parse(item['hora_inicio']).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(item['hora_inicio']).toLocal().minute.toString().padLeft(2, '0')}"
          : '00:00',
      endTime: item['hora_fin'] != null
          ? "${DateTime.parse(item['hora_fin']).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(item['hora_fin']).toLocal().minute.toString().padLeft(2, '0')}"
          : '00:00',
      status: _mapStatus(item['estado_reserva']),
      department: u['especialidad'] as String? ?? u['carrera'] as String? ?? '',
      priority: RequestPriority.normal,
      userAvatarUrl: u['foto_url'] as String?,
      notes: item['notas'] as String?,
      isRead: item['leido_por_admin'] as bool? ?? false,
      createdAt: item['creado_en'] != null ? DateTime.parse(item['creado_en']) : null,
    );
  }

  ReservationStatus _mapStatus(String? status) {
    if (status == null) return ReservationStatus.pending;
    switch (status.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return ReservationStatus.approved;
      case 'rechazada':
      case 'rechazado':
      case 'desaprobado':
        return ReservationStatus.rejected;
      case 'en_curso':
        return ReservationStatus.inProgress;
      case 'finalizada':
      case 'completado':
        return ReservationStatus.completed;
      case 'cancelada':
      case 'cancelado':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }

  String _mapStatusToString(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.approved:
        return 'aprobada';
      case ReservationStatus.rejected:
        return 'rechazada';
      case ReservationStatus.inProgress:
        return 'en_curso';
      case ReservationStatus.completed:
        return 'finalizada';
      case ReservationStatus.cancelled:
        return 'cancelada';
      default:
        return 'pendiente';
    }
  }
}