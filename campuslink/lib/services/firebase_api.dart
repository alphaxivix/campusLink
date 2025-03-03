import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseAPI {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initFCM() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Initialize local notifications
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _localNotifications.initialize(initSettings);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message: ${message.notification?.title}");
      showNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Background Message: ${message.notification?.title}");
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
        0, message.notification?.title, message.notification?.body, notificationDetails);
  }
}
