import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/canal_entity.dart';
import '../../domain/entities/mensaje_entity.dart';
import '../../domain/repositories/i_messaging_repository.dart';
import '../../../../core/services/local_storage_service.dart';

class MessagingProvider extends ChangeNotifier {
  final IMessagingRepository _repository;
  final LocalStorageService _localStorageService;

  MessagingProvider(this._repository)
    : _localStorageService = LocalStorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CanalEntity> _canales = [];
  List<CanalEntity> get canales => _canales;

  CanalEntity? _selectedCanal;
  CanalEntity? get selectedCanal => _selectedCanal;

  List<MensajeEntity> _mensajes = [];
  List<MensajeEntity> get mensajes => _mensajes;

  StreamSubscription? _mensajesSubscription;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  /// Mensajes pendientes que fallaron y pueden reintentar
  final Map<String, _PendingMessage> _pendingMessages = {};

  void selectImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> loadCanales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _canales = await _repository.getActiveCanales();
    } catch (e) {
      debugPrint('Error loading canales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCanal(CanalEntity canal) {
    _selectedCanal = canal;
    _mensajes = [];
    notifyListeners();
    _subscribeToMensajes(canal.id);
  }

  /// Opens/creates canal for a reservation and selects it.
  Future<CanalEntity> openCanalForReserva(String reservaId) async {
    final canal = await _repository.getOrCreateCanal(reservaId);
    selectCanal(canal);
    return canal;
  }

  void clearSelectedCanal() {
    _mensajesSubscription?.cancel();
    _mensajesSubscription = null;
    _selectedCanal = null;
    _mensajes = [];
    notifyListeners();
  }

  void _subscribeToMensajes(String canalId) {
    _mensajesSubscription?.cancel();
    _mensajesSubscription = _repository
        .getMensajesStream(canalId)
        .listen(
          (nuevosMensajes) {
            // Merge: keep optimistic (sending) + replace confirmed ones
            final optimistic = _mensajes
                .where(
                  (m) =>
                      m.estado == MensajeEstado.enviando ||
                      m.estado == MensajeEstado.error,
                )
                .toList();

            final serverIds = nuevosMensajes.map((m) => m.id).toSet();
            // Remove optimistic messages that server already confirmed
            final stillPending = optimistic
                .where((m) => !serverIds.contains(m.id))
                .toList();

            _mensajes = [...nuevosMensajes, ...stillPending];
            _mensajes.sort((a, b) => a.creadoEn.compareTo(b.creadoEn));
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Error en stream de mensajes: $e');
          },
        );
  }

  /// Envía con Optimistic UI: muestra burbuja inmediata, sube en background.
  Future<void> enviarMensaje(String texto) async {
    if (_selectedCanal == null) return;
    if (texto.trim().isEmpty && _selectedImage == null) return;

    final canalId = _selectedCanal!.id;
    final now = DateTime.now();
    final tempId = 'temp_${now.millisecondsSinceEpoch}';

    // 1. Cache image locally if present
    File? cachedImage;
    String? localPath;
    if (_selectedImage != null) {
      cachedImage = await _localStorageService.saveImageToTemp(
        sourceFile: _selectedImage!,
        fileName: _localStorageService.generateTempFileName(),
      );
      localPath = cachedImage.path;
    }

    final textoFinal = texto.trim().isNotEmpty ? texto.trim() : null;

    // 2. Create optimistic message entity (show instantly)
    final optimisticMsg = MensajeEntity(
      id: tempId,
      canalId: canalId,
      remitenteId: '', // filled by UI via currentUserId check
      texto: textoFinal,
      archivoUrl: null,
      archivoLocalPath: localPath,
      estado: MensajeEstado.enviando,
      creadoEn: now,
      expiraEn: now.add(const Duration(hours: 24)),
    );

    _mensajes = [..._mensajes, optimisticMsg];
    _pendingMessages[tempId] = _PendingMessage(
      canalId: canalId,
      texto: textoFinal,
      imagen: cachedImage,
      localPath: localPath,
    );
    clearSelectedImage();
    notifyListeners();

    // 3. Background upload
    await _uploadInBackground(tempId);
  }

  /// Reintenta un mensaje que falló.
  Future<void> retryMessage(String tempId) async {
    final idx = _mensajes.indexWhere((m) => m.id == tempId);
    if (idx == -1) return;

    _mensajes[idx] = _mensajes[idx].copyWith(estado: MensajeEstado.enviando);
    notifyListeners();

    await _uploadInBackground(tempId);
  }

  Future<void> _uploadInBackground(String tempId) async {
    final pending = _pendingMessages[tempId];
    if (pending == null) return;

    try {
      await _repository.enviarMensaje(
        canalId: pending.canalId,
        texto: pending.texto,
        imagen: pending.imagen,
      );

      // On success: remove optimistic placeholder (server stream will push real msg)
      _mensajes.removeWhere((m) => m.id == tempId);
      _pendingMessages.remove(tempId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error subiendo mensaje: $e');
      // Mark as error so user can retry
      final idx = _mensajes.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        _mensajes[idx] = _mensajes[idx].copyWith(estado: MensajeEstado.error);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _mensajesSubscription?.cancel();
    super.dispose();
  }
}

class _PendingMessage {
  final String canalId;
  final String? texto;
  final File? imagen;
  final String? localPath;

  _PendingMessage({
    required this.canalId,
    this.texto,
    this.imagen,
    this.localPath,
  });
}
