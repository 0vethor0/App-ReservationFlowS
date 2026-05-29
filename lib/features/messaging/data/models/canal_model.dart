import '../../domain/entities/canal_entity.dart';

class CanalModel extends CanalEntity {
  const CanalModel({
    required super.id,
    required super.reservaId,
    required super.usuarioId,
    required super.estado,
    required super.creadoEn,
  });

  factory CanalModel.fromMap(Map<String, dynamic> map) {
    return CanalModel(
      id: map['id'] as String,
      reservaId: map['reserva_id'] as String,
      usuarioId: map['usuario_id'] as String,
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
