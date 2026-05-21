import '../../../reservations/domain/entities/reservation_entity.dart';

abstract class ViewReservationCalendarRepository {
  /// Fetch all reservations for a specific date
  Future<List<ReservationEntity>> fetchReservationsForDate(DateTime date);
}
