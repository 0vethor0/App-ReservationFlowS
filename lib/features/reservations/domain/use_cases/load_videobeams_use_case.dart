/// Use case for loading available videobeams.
library;

import '../repositories/reservation_repository.dart';
import '../entities/videobeam_entity.dart';

class LoadVideobeamsUseCase {
  final ReservationRepository repository;

  LoadVideobeamsUseCase(this.repository);

  Future<List<VideobeamEntity>> call() {
    return repository.loadVideobeams();
  }
}
