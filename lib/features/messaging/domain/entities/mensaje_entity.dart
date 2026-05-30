/// Estado de envío del mensaje para Optimistic UI.
enum MensajeEstado { enviando, enviado, error }

class MensajeEntity {
  final String id;
  final String canalId;
  final String remitenteId;
  final String? texto;
  final String? archivoUrl;
  final String? archivoLocalPath; // Ruta local para UX optimista
  final MensajeEstado estado; // ⏳ enviando, ✅ enviado, ❌ error
  final DateTime creadoEn;
  final DateTime expiraEn;

  const MensajeEntity({
    required this.id,
    required this.canalId,
    required this.remitenteId,
    this.texto,
    this.archivoUrl,
    this.archivoLocalPath,
    this.estado = MensajeEstado.enviado,
    required this.creadoEn,
    required this.expiraEn,
  });

  /// Crea copia con campos reemplazados (para transiciones optimistas).
  MensajeEntity copyWith({
    String? id,
    String? canalId,
    String? remitenteId,
    String? texto,
    String? archivoUrl,
    String? archivoLocalPath,
    MensajeEstado? estado,
    DateTime? creadoEn,
    DateTime? expiraEn,
  }) {
    return MensajeEntity(
      id: id ?? this.id,
      canalId: canalId ?? this.canalId,
      remitenteId: remitenteId ?? this.remitenteId,
      texto: texto ?? this.texto,
      archivoUrl: archivoUrl ?? this.archivoUrl,
      archivoLocalPath: archivoLocalPath ?? this.archivoLocalPath,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
      expiraEn: expiraEn ?? this.expiraEn,
    );
  }
}
