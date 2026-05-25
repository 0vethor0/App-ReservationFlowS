abstract class NotificationService {
  Future<void> initialize();
  Future<String?> getDeviceToken();
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  });
}