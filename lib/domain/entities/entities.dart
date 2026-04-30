/// Entidades del dominio para BeamReserve.
///
/// Clases puras de Dart sin dependencias externas.

class UserEntity {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.department,
    this.role = UserRole.user,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? department;
  final UserRole role;
}

enum UserRole { user, admin }

class VideobeamEntity {
  const VideobeamEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.location,
    this.status = VideobeamStatus.available,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String brand;
  final String model;
  final String location;
  final VideobeamStatus status;
  final String? imageUrl;
}

enum VideobeamStatus { available, inUse, maintenance }

class ReservationEntity {
  const ReservationEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.videobeamId,
    required this.videobeamName,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = ReservationStatus.pending,
    this.department,
    this.priority = RequestPriority.normal,
    this.userAvatarUrl,
  });

  final String id;
  final String userId;
  final String userName;
  final String videobeamId;
  final String videobeamName;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final ReservationStatus status;
  final String? department;
  final RequestPriority priority;
  final String? userAvatarUrl;
}

enum ReservationStatus { pending, approved, rejected, completed, cancelled }

enum RequestPriority { normal, high }

class DashboardMetrics {
  const DashboardMetrics({
    this.reservationsToday = 0,
    this.availableEquipment = 0,
    this.totalEquipment = 0,
    this.inMaintenance = 0,
    this.inUseNow = 0,
    this.pendingRequests = 0,
    this.weeklyUtilization = const [],
  });

  final int reservationsToday;
  final int availableEquipment;
  final int totalEquipment;
  final int inMaintenance;
  final int inUseNow;
  final int pendingRequests;
  final List<double> weeklyUtilization;
}
