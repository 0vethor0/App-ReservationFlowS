import '../repositories/reservation_repository.dart';

class CreateMultipleReservationsUseCase {
  final ReservationRepository repository;

  CreateMultipleReservationsUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required String productId,
    required List<Map<String, dynamic>> dates,
    String? globalNotes,
  }) async {
    return repository.createMultipleReservations(
      userId: userId,
      productId: productId,
      dates: dates,
      globalNotes: globalNotes,
    );
  }
}
