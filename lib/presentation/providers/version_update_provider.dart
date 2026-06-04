// lib/presentation/providers/version_update_provider.dart
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VersionUpdateProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  StreamSubscription? _realtimeSubscription;
  StreamSubscription<DownloadInfo>? _downloadSubscription;

  double _progresoDescarga = 0.0;
  double get progresoDescarga => _progresoDescarga;

  bool _descargando = false;
  bool get descargando => _descargando;

  String _estadoDescarga = '';
  String get estadoDescarga => _estadoDescarga;

  /// Abre el canal WebSocket. Llamar una sola vez desde el widget raíz.
  Future<void> inicializarEscuchaDeVersiones(BuildContext context) async {
    await _realtimeSubscription?.cancel();

    final packageInfo = await PackageInfo.fromPlatform();
    // buildNumber viene del campo después del '+' en pubspec.yaml
    // ej. "1.1.0+10100" → buildNumber = "10100"
    final int versionInstalada = int.tryParse(packageInfo.buildNumber) ?? 0;

    if (versionInstalada == 0) {
      // En debug el buildNumber puede estar vacío. No alertar.
      debugPrint('[OTA] buildNumber no disponible, omitiendo verificación.');
      return;
    }

    _realtimeSubscription = _supabase
        .from('versiones_app')
        .stream(primaryKey: ['id'])
        .order('version_codigo', ascending: false)
        .limit(1)
        .listen(
          (List<Map<String, dynamic>> snapshot) {
            if (snapshot.isEmpty) return;

            final datos = snapshot.first;
            final int versionServidor = (datos['version_codigo'] as num)
                .toInt();
            final String urlDescarga = datos['url_descarga'] as String;
            final String versionNombre = datos['version_nombre'] as String;

            if (versionServidor > versionInstalada) {
              if (context.mounted) {
                _mostrarAlertaActualizacion(
                  context,
                  versionNombre,
                  urlDescarga,
                );
              }
            }
          },
          onError: (error) {
            debugPrint('[OTA] Error en canal Realtime: $error');
          },
        );
  }

  Future<void> descargarEInstalarApk(String url) async {
    _descargando = true;
    _progresoDescarga = 0.0;
    _estadoDescarga = 'Iniciando descarga...';
    notifyListeners();

    try {
      // Iniciar la descarga. RUpgrade.upgrade retorna un int (download id).
      await RUpgrade.upgrade(
        url,
        fileName: 'beamflow_update.apk', // nombre del archivo local
        installType:
            RUpgradeInstallType.normal, // instala automáticamente al terminar
        useDownloadManager: false, // usar servicio propio (soporta https)
        notificationStyle:
            NotificationStyle.speechAndPlanTime, // "100kb/s  1s left"
      );

      // Cancelar suscripción anterior si existía
      await _downloadSubscription?.cancel();

      // Escuchar el progreso desde el stream de r_upgrade
      _downloadSubscription = RUpgrade.stream.listen(
        (DownloadInfo info) {
          switch (info.status) {
            case DownloadStatus.STATUS_RUNNING:
              _progresoDescarga = (info.percent ?? 0) / 100.0;
              final speed = info.speed?.toStringAsFixed(0) ?? '0';
              _estadoDescarga =
                  'Descargando... ${info.percent?.toStringAsFixed(0)}%  ($speed kb/s)';
              notifyListeners();
              break;

            case DownloadStatus.STATUS_SUCCESSFUL:
              _descargando = false;
              _progresoDescarga = 1.0;
              _estadoDescarga = 'Instalando...';
              notifyListeners();
              break;

            case DownloadStatus.STATUS_FAILED:
              _descargando = false;
              _estadoDescarga = 'Error en la descarga. Intenta de nuevo.';
              notifyListeners();
              debugPrint('[OTA] Descarga fallida.');
              break;

            case DownloadStatus.STATUS_PAUSED:
              _estadoDescarga = 'Descarga pausada.';
              notifyListeners();
              break;

            default:
              break;
          }
        },
        onError: (error) {
          _descargando = false;
          _estadoDescarga = 'Error inesperado: $error';
          notifyListeners();
          debugPrint('[OTA] Error en stream de descarga: $error');
        },
      );
    } catch (e) {
      _descargando = false;
      _estadoDescarga = 'No se pudo iniciar la actualización.';
      notifyListeners();
      debugPrint('[OTA] Excepción al iniciar descarga: $e');
    }
  }

  void _mostrarAlertaActualizacion(
    BuildContext context,
    String nombre,
    String url,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          // StatefulBuilder permite que el dialog se actualice con el progreso
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Actualización Disponible ($nombre)'),
              content: _descargando
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(value: _progresoDescarga),
                        const SizedBox(height: 12),
                        Text(
                          _estadoDescarga,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    )
                  : const Text(
                      'Hay una nueva versión disponible. Es necesario instalarla para continuar usando el sistema.',
                    ),
              actions: [
                if (!_descargando)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      descargarEInstalarApk(url);
                    },
                    child: const Text('Actualizar'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _downloadSubscription?.cancel();
    super.dispose();
  }
}
