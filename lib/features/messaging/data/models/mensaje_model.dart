import '../../domain/entities/mensaje_entity.dart';

class MensajeModel extends MensajeEntity {
  const MensajeModel({
    required super.id,
    required super.canalId,
    required super.remitenteId,
    super.texto,
    super.archivoUrl,
    super.archivoLocalPath,
    super.estado = MensajeEstado.enviado,
    required super.creadoEn,
    required super.expiraEn,
  });

  factory MensajeModel.fromMap(Map<String, dynamic> map) {
    return MensajeModel(
      id: map['id'] as String,
      canalId: map['canal_id'] as String,
      remitenteId: map['remitente_id'] as String,
      texto: map['texto'] as String?,
      archivoUrl: map['archivo_url'] as String?,
      creadoEn: DateTime.parse(map['creado_en'] as String).toLocal(),
      expiraEn: DateTime.parse(map['expira_en'] as String).toLocal(),
      estado: MensajeEstado.enviado,
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'id': id,
      'canal_id': canalId,
      'remitente_id': remitenteId,
      'creado_en': creadoEn.toUtc().toIso8601String(),
      'expira_en': expiraEn.toUtc().toIso8601String(),
    };
    if (texto != null) data['texto'] = texto;
    if (archivoUrl != null) data['archivo_url'] = archivoUrl;
    return data;
  }
}
