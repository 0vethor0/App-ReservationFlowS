/// Entity representing a user pending approval (registration or admin promotion).
library;

enum PendingApprovalKind { registration, adminPromotion }

class PendingUserEntity {
  const PendingUserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.especialidad,
    required this.carrera,
    required this.kind,
    this.avatarUrl,
    required this.registeredAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final DateTime registeredAt;
  final String? especialidad;
  final String? carrera;
  final PendingApprovalKind kind;
}
