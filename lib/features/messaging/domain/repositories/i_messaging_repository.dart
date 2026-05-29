import 'dart:io';
import '../entities/canal_entity.dart';
import '../entities/mensaje_entity.dart';

abstract class IMessagingRepository {
  /// Obtiene o crea un canal para una reserva específica
  Future<CanalEntity> getOrCreateCanal(String reservaId);

  /// Obtiene la lista de canales activos (para el usuario actual o todos si es admin)
  Future<List<CanalEntity>> getActiveCanales();

  /// Se suscribe al stream de mensajes de un canal
  Stream<List<MensajeEntity>> getMensajesStream(String canalId);

  /// Envía un mensaje de texto o imagen
  Future<void> enviarMensaje({
    required String canalId,
    String? texto,
    File? imagen,
  });
}
