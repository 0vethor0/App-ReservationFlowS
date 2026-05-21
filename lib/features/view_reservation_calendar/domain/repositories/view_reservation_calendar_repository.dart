import '../../../reservations/domain/entities/reservation_entity.dart';
import '../entities/calendar_product_entity.dart';
import '../entities/calendar_status_filter.dart';

abstract class ViewReservationCalendarRepository {
  Future<List<ReservationEntity>> fetchReservationsForDate(DateTime date);

  Future<List<CalendarProductEntity>> fetchProducts();

  Future<List<ReservationEntity>> fetchCalendarReservations({
    String? productId,
    required CalendarStatusFilter statusFilter,
  });

  Stream<void> watchReservationsChanges();
  void disposeRealtime();
}
