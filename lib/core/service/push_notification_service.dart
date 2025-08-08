import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission();
    print("FCM Permission granted");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.notification?.title}');
    });
  }

  Future<void> subscribeToUserTopic(String email) async {
    final topic = _sanitizeEmail(email);
    await _fcm.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromUserTopic(String email) async {
    final topic = _sanitizeEmail(email);
    await _fcm.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  String _sanitizeEmail(String email) {
    return email.replaceAll(RegExp(r'[^\w]'), '_');
  }

  Future<void> initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    const initSettings = InitializationSettings(android: androidInit);

    // Handling background notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🌟 Background Notification Tapped!");
    });
  }

  Future<void> showHeadsUpNotification(RemoteMessage message) async {
    try {
      // Android notification settings with heads-up notification (full-screen)
      const androidDetails = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'ticker',
        fullScreenIntent: true,
      );
      const platformDetails = NotificationDetails(android: androidDetails);

      // Show the notification as a heads-up notification
      await _flutterLocalNotificationsPlugin.show(
        0, // notification id
        message.data['username'],
        message.data['text'],

        // ?? message.data['img'] ?? message.data['url'],
        platformDetails,
        payload: message.data.toString(),
      );
    } catch (e) {
      print("🔥 Error showing heads-up notification: $e");
    }
  }
}
