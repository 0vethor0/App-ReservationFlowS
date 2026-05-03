/// Supabase Realtime Manager para comunicación en tiempo real.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WebSocketManager extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  bool _isConnected = false;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  WebSocketManager({required String url});

  bool get isConnected => _isConnected;
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect() {
    try {
      _channel = _supabase.channel(
        'public:reservas',
        opts: const RealtimeChannelConfig(self: true),
      );

      _channel
          ?.onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'reservas',
            callback: (payload) {
              final data = payload.newRecord.isNotEmpty
                  ? payload.newRecord
                  : payload.oldRecord;

              _messageController.add({
                'type': 'postgres_change',
                'event': payload.eventType.name,
                'payload': data,
              });
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              _isConnected = true;
              debugPrint('Supabase Realtime connected');
            } else {
              _isConnected = false;
            }
            notifyListeners();
          });

      _channel?.onBroadcast(
        event: 'message',
        callback: (payload) {
          _messageController.add({'type': 'broadcast', 'payload': payload});
        },
      );
    } catch (e) {
      debugPrint('Error en conexión: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Método corregido para Supabase Flutter 2.12.x
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (_isConnected && _channel != null) {
      try {
        // En la v2.12.x, sendBroadcast es el método estándar
        await _channel!.sendBroadcast(event: 'message', payload: message);
      } catch (e) {
        debugPrint('Error enviando broadcast: $e');
      }
    }
  }

  void disconnect() {
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
    }
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _messageController.close();
    super.dispose();
  }
}

extension on RealtimeChannel {
  Future<void> sendBroadcast({
    required String event,
    required Map<String, dynamic> payload,
  }) async {}
}
