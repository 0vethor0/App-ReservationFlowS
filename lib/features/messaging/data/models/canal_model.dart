import '../../domain/entities/canal_entity.dart';

class CanalModel extends CanalEntity {
  const CanalModel({
    required super.id,
    required super.reservaId,
    required super.usuarioId,
    super.userName,
    super.userSpecialty,
    required super.estado,
    required super.creadoEn,
  });

  factory CanalModel.fromMap(Map<String, dynamic> map) {
    final perfilesData = map['perfiles'];
    String? userName;
    String? userSpecialty;

    if (perfilesData is Map<String, dynamic>) {
      userName =
          '${perfilesData['primer_nombre'] ?? ''} ${perfilesData['primer_apellido'] ?? ''}'
              .trim();
      if (userName.isEmpty) userName = null;
      userSpecialty = perfilesData['especialidad'] as String? ??
          perfilesData['carrera'] as String?;
    }

    return CanalModel(
      id: map['id'] as String,
      reservaId: map['reserva_id'] as String,
      usuarioId: map['usuario_id'] as String,
      userName: userName,
      userSpecialty: userSpecialty,
      estado: map['estado'] as String,
      creadoEn: DateTime.parse(map['creado_en'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reserva_id': reservaId,
      'usuario_id': usuarioId,
      'estado': estado,
      'creado_en': creadoEn.toUtc().toIso8601String(),
    };
  }
}
