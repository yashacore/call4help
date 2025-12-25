import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_flutter/screens/provider_screens/provider_service_details_screen.dart';
import 'package:first_flutter/screens/user_screens/user_custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String _customSoundFileName = 'notification_sound';

  static Future<void> initializeNotifications() async {
    await _setupLocalNotifications();

    await _createNotificationChannel();

    await _setForegroundOptions();

    _setupForegroundMessageHandler();

    _setupBackgroundMessageHandler();

    await _checkInitialMessage();

    setupTokenRefreshListener();
  }

  static Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint("📱 Notification tapped: ${response.payload}");
        _handleNotificationTap(response.payload);
      },
    );
    debugPrint("✅ Local notifications initialized");
  }

  // Create Android Notification Channel with Custom Sound
  static Future<void> _createNotificationChannel() async {
    final androidSound = RawResourceAndroidNotificationSound(
      _customSoundFileName,
    );

    final channel = AndroidNotificationChannel(
      'moyo_high_importance_custom',
      'call4help Custom Notifications',
      description: 'Notifications with custom sound',
      importance: Importance.max,
      playSound: true,
      sound: androidSound,
      // 🔊 Custom sound
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    debugPrint("✅ Channel created with custom sound: ${channel.id}");
    debugPrint("🔊 Sound file: $_customSoundFileName");
  }

  // Set Foreground Notification Options for iOS
  static Future<void> _setForegroundOptions() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("✅ iOS foreground options set");
  }

  // ================== MESSAGE HANDLERS ==================

  // Handle Foreground Messages (App is Open)
  static void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("=== 🔔 FOREGROUND Message Received ===");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
      debugPrint("Data: ${message.data}");

      // Show local notification when app is in foreground
      _showLocalNotification(message);
    });
  }

  // Handle Background Message Taps (App in Background)
  static void _setupBackgroundMessageHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("=== 🔔 App Opened from BACKGROUND ===");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Data: ${message.data}");
      _handleNotificationTap(jsonEncode(message.data));
    });
  }

  // Check if App Opened from Terminated State
  static Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      debugPrint("=== 🔔 App Opened from TERMINATED State ===");
      debugPrint("Title: ${initialMessage.notification?.title}");
      // Delay navigation to ensure app is fully initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(jsonEncode(initialMessage.data));
      });
    }
  }

  // Show Local Notification with Custom Sound (Instance method)
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    debugPrint("=== 📲 Showing notification with custom sound ===");

    final androidDetails = AndroidNotificationDetails(
      'moyo_high_importance_custom',
      'call4help Custom Notifications',
      channelDescription: 'Notifications with custom sound',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_customSoundFileName),
      // 🔊 Custom sound
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      ticker: 'New Notification',
      styleInformation: const BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      notificationDetails,
      payload: jsonEncode(message.data),
    );

    debugPrint("✅ Notification shown with custom sound");
  }

  // 🔥 STATIC METHOD: Background handler ke liye (Plugin initialize karne ke baad)
  static Future<void> showLocalNotificationStatic(RemoteMessage message) async {
    debugPrint(
      "=== 📲 [BACKGROUND] Showing notification with custom sound ===",
    );

    // Plugin ko initialize karo agar background se call ho raha hai
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Channel ko phir se create karo (background mein zaruri hai)
    final androidSound = RawResourceAndroidNotificationSound(
      _customSoundFileName,
    );
    final channel = AndroidNotificationChannel(
      'moyo_high_importance_custom',
      'call4help Custom Notifications',
      description: 'Notifications with custom sound',
      importance: Importance.max,
      playSound: true,
      sound: androidSound,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Notification details
    final androidDetails = AndroidNotificationDetails(
      'moyo_high_importance_custom',
      'call4help Custom Notifications',
      channelDescription: 'Notifications with custom sound',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_customSoundFileName),
      // 🔊 Custom sound
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      ticker: 'New Notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Notification show karo
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      notificationDetails,
      payload: jsonEncode(message.data),
    );

    debugPrint("✅ [BACKGROUND] Notification shown with custom sound");
  }

  // Handle Notification Tap with proper navigation
  static void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      debugPrint("⚠️ Empty payload received");
      return;
    }

    debugPrint("🔔 Handling notification tap with payload: $payload");

    try {
      final Map<String, dynamic> data = jsonDecode(payload);

      if (data.containsKey("serviceId") && data.containsKey("role")) {
        String serviceId = data["serviceId"].toString();
        String role = data["role"].toString();

        debugPrint("📍 Role: $role, ServiceId: $serviceId");

        final context = navigatorKey.currentContext;

        if (context != null) {
          if (role == "user") {
            // ✅ User role - Navigate to UserCustomBottomNav with UserService tab
            _navigateToUserServiceFromNotification(context, serviceId);
          } else if (role == "provider") {
            // Provider role
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProviderServiceDetailsScreen(serviceId: serviceId),
              ),
            );
          }
        } else {
          debugPrint("❌ Navigator context not available");
        }
      }
    } catch (e) {
      debugPrint("❌ Error parsing payload: $e");
    }
  }

  // ✅ Navigate to UserService tab with serviceId
  static Future<void> _navigateToUserServiceFromNotification(
    BuildContext context,
    String serviceId,
  ) async {
    try {
      // ✅ First navigate to UserCustomBottomNav with Services tab
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => UserCustomBottomNav(
            initialTab: 2, // ✅ Services tab index
            notificationServiceId: serviceId, // ✅ Pass serviceId
          ),
        ),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      debugPrint("❌ Error navigating: $e");
    }
  }

  // ================== PERMISSIONS ==================

  static Future<bool> requestNotificationPermission(
    BuildContext context,
  ) async {
    debugPrint("=== 📢 Requesting Notification Permission ===");

    final prefs = await SharedPreferences.getInstance();
    final hasAsked = prefs.getBool('notification_permission_asked') ?? false;

    final settings = await _firebaseMessaging.getNotificationSettings();
    debugPrint("Current permission: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("✅ Permission already granted");
      await _getAndSaveToken();
      return true;
    }

    if (settings.authorizationStatus == AuthorizationStatus.denied &&
        hasAsked) {
      debugPrint("❌ Permission previously denied");
      return false;
    }

    final granted = await _showPermissionDialog(context);
    await prefs.setBool('notification_permission_asked', true);

    if (granted) {
      await _getAndSaveToken();
    }

    return granted;
  }

  static Future<bool> _showPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Enable Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stay updated with important information:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildBenefitItem(Icons.receipt, 'Bill payment reminders'),
              _buildBenefitItem(Icons.event, 'Event notifications'),
              _buildBenefitItem(Icons.campaign, 'Important announcements'),
              _buildBenefitItem(Icons.check_circle, 'Service updates'),
              const SizedBox(height: 12),
              Text(
                'You can change this later in settings.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Not Now',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Allow',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      debugPrint("User agreed, requesting system permission...");

      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('✅ System permission granted');
        return true;
      } else {
        debugPrint('❌ System permission denied');
        return false;
      }
    }

    debugPrint("User clicked 'Not Now'");
    return false;
  }

  static Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // ================== TOKEN MANAGEMENT ==================

  static Future<void> _getAndSaveToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint("🔑 FCM Token: $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        debugPrint("✅ Token saved locally");
      } else {
        debugPrint("❌ Failed to get FCM token");
      }
    } catch (e) {
      debugPrint("❌ Error getting token: $e");
    }
  }

  static Future<String?> getDeviceToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedToken = prefs.getString('fcm_token');

      if (cachedToken != null) {
        debugPrint("📱 Using cached token");
        return cachedToken;
      }

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await prefs.setString('fcm_token', token);
        debugPrint("🔑 Fresh token retrieved");
      }
      return token;
    } catch (e) {
      debugPrint("❌ Error getting token: $e");
      return null;
    }
  }

  static void setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 Token refreshed: $newToken");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', newToken);
    });
  }

  // ================== TEST METHODS ==================

  static Future<void> showTestNotification() async {
    debugPrint("=== 🧪 Showing Test Notification ===");

    final androidDetails = AndroidNotificationDetails(
      'moyo_high_importance_custom',
      'call4help Custom Notifications',
      channelDescription: 'Notifications with custom sound',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_customSoundFileName),
      enableVibration: true,
      enableLights: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      '🧪 Custom Sound Test',
      'Agar aapki custom sound sunayi di, toh kaam ho gaya! 🎉',
      notificationDetails,
    );

    debugPrint("✅ Test notification triggered");
  }

  static Future<void> deleteOldChannel() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel('call4help_high_importance');

    debugPrint("🗑️ Old channel deleted");
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }


  static Future<void> showForegroundNotification(
      String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  static void init() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showForegroundNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',
        );
      }
    });
  }
}
