/// User entity for authentication domain.
///
/// Pure Dart class without external dependencies.
library;

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

enum UserRole { user, admin, superAdmin }
