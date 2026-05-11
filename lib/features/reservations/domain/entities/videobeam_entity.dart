/// Videobeam entity for reservations domain.
///
/// Pure Dart class without external dependencies.
library;

class VideobeamEntity {
  const VideobeamEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    this.status = VideobeamStatus.available,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String brand;
  final String model;
  final VideobeamStatus status;
  final String? imageUrl;
}

enum VideobeamStatus { available, inUse, maintenance }
