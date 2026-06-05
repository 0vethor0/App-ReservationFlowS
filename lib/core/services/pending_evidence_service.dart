/// Servicio para persistir el estado de evidencia pendiente cuando Android
/// destruye la Activity durante la captura de imagen con la cámara.
///
/// Guarda el ID de la reservación en un archivo JSON en el directorio de la app
/// para poder recuperar el contexto al volver de la cámara.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PendingEvidenceService {
  static const _fileName = 'pending_evidence.json';

  static PendingEvidenceService? _instance;
  static PendingEvidenceService get instance =>
      _instance ??= PendingEvidenceService._();

  PendingEvidenceService._();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Guarda el ID de la reservación pendiente antes de abrir la cámara/galería.
  Future<void> savePending(String reservationId) async {
    try {
      final file = await _file;
      final data = jsonEncode({
        'reservation_id': reservationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await file.writeAsString(data);
      debugPrint('[PendingEvidence] Guardado: $reservationId');
    } catch (e) {
      debugPrint('[PendingEvidence] Error guardando: $e');
    }
  }

  /// Retorna el ID de la reservación pendiente, o null si no hay.
  Future<String?> getPendingReservationId() async {
    try {
      final file = await _file;
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      if (content.isEmpty) return null;

      final data = jsonDecode(content) as Map<String, dynamic>;
      final timestamp = DateTime.tryParse(data['timestamp'] ?? '');

      // Expirar después de 10 minutos para evitar datos obsoletos
      if (timestamp != null &&
          DateTime.now().difference(timestamp).inMinutes > 10) {
        await clearPending();
        debugPrint('[PendingEvidence] Expirado, limpiando');
        return null;
      }

      return data['reservation_id'] as String?;
    } catch (e) {
      debugPrint('[PendingEvidence] Error leyendo: $e');
      return null;
    }
  }

  /// Limpia el estado pendiente.
  Future<void> clearPending() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
        debugPrint('[PendingEvidence] Limpiado');
      }
    } catch (e) {
      debugPrint('[PendingEvidence] Error limpiando: $e');
    }
  }
}
