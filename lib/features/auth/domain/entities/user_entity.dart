/// User entity for authentication domain.
///
/// Pure Dart class without external dependencies.
library;

class UserEntity {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.department,
    this.role = UserRole.user,
    this.status = UserStatus.pending,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? department;
  final UserRole role;
  final UserStatus status;
}

enum UserRole { user, admin, superAdmin }

enum UserStatus { pending, approved, rejected }
