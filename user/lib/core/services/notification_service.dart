import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio para gestionar las notificaciones locales de la aplicación
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService(this._notificationsPlugin);

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  /// Muestra una notificación simple
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'rushgo_channel',
      'RushGo Notificaciones',
      channelDescription: 'Canal para notificaciones de RushGo',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Cancela una notificación específica
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
