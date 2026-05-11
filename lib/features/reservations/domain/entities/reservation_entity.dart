/// Reservation entity for reservations domain.
///
/// Pure Dart class without external dependencies.
library;

class ReservationEntity {
  const ReservationEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.videobeamId,
    required this.videobeamName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = ReservationStatus.pending,
    this.department,
    this.priority = RequestPriority.normal,
    this.userAvatarUrl,
    this.notes,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String videobeamId;
  final String videobeamName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final ReservationStatus status;
  final String? department;
  final RequestPriority priority;
  final String? userAvatarUrl;
  final String? notes;
  final bool isRead;
  final DateTime? createdAt;
}

enum ReservationStatus { pending, approved, rejected, completed, cancelled }

enum RequestPriority { normal, high }
