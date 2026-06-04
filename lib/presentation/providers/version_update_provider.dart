// lib/presentation/providers/version_update_provider.dart
library;

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VersionUpdateProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  StreamSubscription? _realtimeSubscription;

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
      // Ruta local donde guardar el APK
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/beamflow_update.apk';
      final file = File(filePath);
      if (await file.exists()) await file.delete();

      // Descarga con progreso
      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          _progresoDescarga = received / total;
          _estadoDescarga =
              'Descargando... ${(_progresoDescarga * 100).toStringAsFixed(0)}%';
          notifyListeners();
        },
      );

      _estadoDescarga = 'Instalando...';
      notifyListeners();

      // Lanzar instalador nativo de Android
      await OpenFilex.open(filePath, type: 'application/vnd.android.package-archive');

      _descargando = false;
      notifyListeners();
    } catch (e) {
      _descargando = false;
      _estadoDescarga = 'Error: $e';
      notifyListeners();
      debugPrint('[OTA] Error descarga/instalación: $e');
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
    super.dispose();
  }
}
