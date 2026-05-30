import '../../domain/entities/calendar_product_entity.dart';
import '../../domain/entities/calendar_status_filter.dart';
import '../../domain/repositories/view_reservation_calendar_repository.dart';
import '../datasources/view_reservation_calendar_remote_datasource.dart';
import '../../../reservations/domain/entities/reservation_entity.dart';

class ViewReservationCalendarRepositoryImpl
    implements ViewReservationCalendarRepository {
  ViewReservationCalendarRepositoryImpl(this.remoteDataSource);

  final ViewReservationCalendarRemoteDataSource remoteDataSource;

  @override
  Future<List<ReservationEntity>> fetchReservationsForDate(
    DateTime date,
  ) async {
    final rawData = await remoteDataSource.fetchReservationsForDate(date);
    return rawData.map(_mapToReservationEntity).toList();
  }

  @override
  Future<List<CalendarProductEntity>> fetchProducts() async {
    final raw = await remoteDataSource.fetchProducts();
    return raw
        .map(
          (item) => CalendarProductEntity(
            id: item['id']?.toString() ?? '',
            name: item['nombre'] as String? ?? 'Videobeam',
          ),
        )
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<ReservationEntity>> fetchCalendarReservations({
    String? productId,
    required CalendarStatusFilter statusFilter,
  }) async {
    final rawData = await remoteDataSource.fetchCalendarReservations(
      productId: productId,
      statusFilter: statusFilter,
    );
    return rawData.map(_mapToReservationEntity).toList();
  }

  @override
  Stream<void> watchReservationsChanges() {
    return remoteDataSource.watchReservationsChanges();
  }

  @override
  void disposeRealtime() {
    remoteDataSource.disposeRealtime();
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
          ? DateTime.parse(item['hora_inicio'] as String).toLocal()
          : DateTime.now(),
      endDateTime: item['hora_fin'] != null
          ? DateTime.parse(item['hora_fin'] as String).toLocal()
          : null,
      startTime: item['hora_inicio'] != null
          ? "${DateTime.parse(item['hora_inicio'] as String).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(item['hora_inicio'] as String).toLocal().minute.toString().padLeft(2, '0')}"
          : '00:00',
      endTime: item['hora_fin'] != null && item['hora_fin'].length > 16
          ? "${DateTime.parse(item['hora_fin'] as String).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(item['hora_fin'] as String).toLocal().minute.toString().padLeft(2, '0')}"
          : '00:00',
      status: _mapStatus(item['estado_reserva']),
      department: u['especialidad'] as String? ?? u['carrera'] as String? ?? '',
      priority: RequestPriority.normal,
      userAvatarUrl: u['foto_url'] as String?,
      notes: item['notas'] as String?,
      isRead: item['leido_por_admin'] as bool? ?? false,
      createdAt: item['creado_en'] != null
          ? DateTime.parse(item['creado_en'] as String)
          : null,
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
}
