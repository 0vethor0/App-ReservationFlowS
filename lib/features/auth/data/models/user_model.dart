/// Model for user data mapping.
///
/// Handles serialization/deserialization between Supabase and domain entity.
library;

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatarUrl,
    super.department,
    super.role,
    super.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Parse role
    final roleStr = map['rol'] as String? ?? 'usuario';
    final role = roleStr == 'super-admin'
        ? UserRole.superAdmin
        : (roleStr == 'admin' ? UserRole.admin : UserRole.user);

    // Parse status
    final statusStr = map['status'] as String? ?? 'pending';
    final status = statusStr == 'approved'
        ? UserStatus.approved
        : (statusStr == 'rejected' ? UserStatus.rejected : UserStatus.pending);

    // Build full name from database fields
    final primerNombre = map['primer_nombre'] as String? ?? '';
    final primerApellido = map['primer_apellido'] as String? ?? '';
    final fullName = '$primerNombre $primerApellido'.trim();

    return UserModel(
      id: map['id'] as String,
      fullName: fullName.isNotEmpty ? fullName : 'Usuario',
      email: map['correo'] as String? ?? '',
      avatarUrl: map['foto_url'] as String?,
      department: map['carrera'] as String?,
      role: role,
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'primer_nombre': fullName.split(' ').first,
      'primer_apellido': fullName.split(' ').length > 1
          ? fullName.split(' ').sublist(1).join(' ')
          : '',
      'correo': email,
      'foto_url': avatarUrl,
      'carrera': department,
      'rol': role.name,
      'status': status.name,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? department,
    UserRole? role,
    UserStatus? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
