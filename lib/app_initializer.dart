import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../NATS Service/NatsService.dart';
import '../data/api_services/NotificationService.dart';
import 'background_handler.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await NotificationService.initializeNotifications();
    NotificationService.setupTokenRefreshListener();

    await NatsService().initialize(
      url: 'nats://api.moyointernational.com',
      autoReconnect: true,
      reconnectInterval: const Duration(seconds: 5),
    );
  }
}
