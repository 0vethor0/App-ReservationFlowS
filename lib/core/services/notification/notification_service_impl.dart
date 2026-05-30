import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

// Debe ser una función global (fuera de cualquier clase), anotada con @pragma
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase requiere reinicializar en el isolate de segundo plano
  await Firebase.initializeApp();
  // No se necesita hacer nada más aquí: cuando la app está cerrada,
  // FCM muestra la notificación automáticamente usando el canal declarado en AndroidManifest.
}

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final String _channelId = 'beamflow_high_importance_channel';
  final String _channelName = 'Notificaciones de Alta Importancia';

  @override
  Future<void> initialize() async {
    // 1. Solicitar permisos al usuario
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      // El usuario denegó los permisos; las notificaciones no funcionarán.
      return;
    }

    // 2. Registrar el manejador de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Configurar notificaciones locales (para cuando la app está en primer plano)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 4. Crear el canal de alta importancia en Android
    //    Esto garantiza las notificaciones flotantes (Heads-up) con sonido del sistema
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 5. Escuchar mensajes cuando la app está ABIERTA (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        String body = notification.body ?? '';
        
        // Ajustar hora en el cuerpo si contiene una hora en formato HH:mm
        // Como se solicitó, ajustar de UTC a UTC-4 (restando 4 horas)
        body = _adjustTimeInBody(body);

        showLocalNotification(
          id: notification.hashCode,
          title: notification.title ?? 'BeamFlow',
          body: body,
          payload: message.data,
        );
      }
    });

    // 6. (Opcional) Escuchar cuando el usuario toca una notificación con la app en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(message.data);
    });
  }

  String _adjustTimeInBody(String body) {
    // Busca patrones de hora HH:mm
    final regExp = RegExp(r'(\d{1,2}):(\d{2})');
    return body.replaceAllMapped(regExp, (match) {
      try {
        int hour = int.parse(match.group(1)!);
        final minute = match.group(2)!;
        
        // Ajuste manual de UTC a UTC-4
        hour = (hour - 4) % 24;
        if (hour < 0) hour += 24;
        
        return '${hour.toString().padLeft(2, '0')}:$minute';
      } catch (e) {
        return match.group(0)!;
      }
    });
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('\u26A0\uFE0F Warning: getDeviceToken() failed - $e');
      return null;
    }
  }

  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            htmlFormatBigText: true,  // Permite HTML
            htmlFormatTitle: true,
          ),
        ),
      ),
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleNavigation(data);
    }
  }

  void _handleNavigation(Map<String, dynamic> data) {
    // Lógica de redirección basada en el tipo de notificación
    final type = data['type'];
    if (type == 'reservation') {
      // ignore: unused_local_variable
      final reservationId = data['reservation_id'];
      // Navegar a la pantalla de detalles de la reserva
      // Ejemplo: NavigationService.pushNamed('/reservations', arguments: reservationId);
    }
  }
}