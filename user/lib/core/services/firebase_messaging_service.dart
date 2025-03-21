import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

/// Servicio para gestionar las notificaciones push de Firebase
class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging;
  final NotificationService _notificationService;

  FirebaseMessagingService({
    required FirebaseMessaging firebaseMessaging,
    required NotificationService notificationService,
  })  : _firebaseMessaging = firebaseMessaging,
        _notificationService = notificationService;

  /// Inicializa el servicio de mensajería de Firebase
  Future<void> initialize() async {
    // Solicitar permisos para notificaciones
    await _requestPermissions();

    // Configurar manejadores de mensajes
    _configureMessageHandlers();

    // Obtener token FCM
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  /// Solicita permisos para notificaciones
  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Configura los manejadores de mensajes
  void _configureMessageHandlers() {
    // Mensaje recibido cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');

      if (message.notification != null) {
        _notificationService.showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'RushGo',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Mensaje abierto cuando la app está en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'Mensaje abierto desde segundo plano: ${message.notification?.title}');
      // Aquí se puede implementar la navegación a una pantalla específica
    });
  }

  /// Suscribe al dispositivo a un tema específico
  Future<void> suscribirATema(String tema) async {
    await _firebaseMessaging.subscribeToTopic(tema);
  }

  /// Desuscribe al dispositivo de un tema específico
  Future<void> desuscribirDeTema(String tema) async {
    await _firebaseMessaging.unsubscribeFromTopic(tema);
  }
}
