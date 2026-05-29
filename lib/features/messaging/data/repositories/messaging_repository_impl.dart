import 'dart:io';
import '../../domain/entities/canal_entity.dart';
import '../../domain/entities/mensaje_entity.dart';
import '../../domain/repositories/i_messaging_repository.dart';
import '../datasources/messaging_remote_datasource.dart';

class MessagingRepositoryImpl implements IMessagingRepository {
  final MessagingRemoteDataSource _remoteDataSource;

  MessagingRepositoryImpl(this._remoteDataSource);

  @override
  Future<CanalEntity> getOrCreateCanal(String reservaId) {
    return _remoteDataSource.getOrCreateCanal(reservaId);
  }

  @override
  Future<List<CanalEntity>> getActiveCanales() {
    return _remoteDataSource.getActiveCanales();
  }

  @override
  Stream<List<MensajeEntity>> getMensajesStream(String canalId) {
    return _remoteDataSource.getMensajesStream(canalId);
  }

  @override
  Future<void> enviarMensaje({
    required String canalId,
    String? texto,
    File? imagen,
  }) {
    return _remoteDataSource.enviarMensaje(
      canalId: canalId,
      texto: texto,
      imagen: imagen,
    );
  }
}
