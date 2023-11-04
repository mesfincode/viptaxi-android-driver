import 'package:driver/screens/notification_detail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future initialize() async {
    // Request permission for notification
    await _firebaseMessaging.requestPermission();

    // Configure FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message has come ---');
      final String? title =
          message.notification?.title ?? message.data['title'];
      final String? body = message.notification?.body ?? message.data['body'];
      print('Message received with title: $title, body: $body');
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        'channel_id',
        'channel_name',
        // 'channel_description',
        
        importance: Importance.high,
        playSound: true,
      );
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        // channel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );
      final NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);
      FlutterLocalNotificationsPlugin()
          .show(0, title ?? '', body ?? '', notificationDetails);
      // Handle incoming message
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the app is opened from a notification
          final String? title = message.notification?.title ?? message.data['title'];
      final String? body = message.notification?.body ?? message.data['body'];
      final Map<String, dynamic> data = message.data;
      _showNotificationDetails(title, body, data);
    });
        final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final String? title = initialMessage.notification?.title ?? initialMessage.data['title'];
      final String? body = initialMessage.notification?.body ?? initialMessage.data['body'];
      final Map<String, dynamic> data = initialMessage.data;
      _showNotificationDetails(title, body, data);
    }
  }

  Future<String?> getDeviceToken() {
    return _firebaseMessaging.getToken();
  }
    void _showNotificationDetails(String? title, String? body, Map<String, dynamic> data) {
    // Navigate to a new screen or dialog to display the notification details
    Get.to(NotificationDetailsScreen(title,body,data));
  }
}
