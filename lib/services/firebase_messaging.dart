import 'package:driver/firebase_options.dart';
import 'package:driver/screens/notification_detail.dart';
import 'package:firebase_core/firebase_core.dart';
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
        
        importance: Importance.max,
        playSound: true,
      );
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        // channel.description,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );
      final NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);
      FlutterLocalNotificationsPlugin()
          .show(0, title ?? '', body ?? '', notificationDetails);
      // Handle incoming message
    });
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
  
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await setupFlutterNotifications();
  // showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // print('Handling a background message ${message.messageId}');
}
void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null ) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}
/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  Future<String?> getDeviceToken() {
    return _firebaseMessaging.getToken();
  }
    void _showNotificationDetails(String? title, String? body, Map<String, dynamic> data) {
    // Navigate to a new screen or dialog to display the notification details
    Get.to(NotificationDetailsScreen(title,body,data));
  }
}
