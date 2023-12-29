import 'package:driver/screens/notification_detail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future initialize() async {
    // Request permission for notification
    await _firebaseMessaging.requestPermission();
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // Configure FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message has come ---');
      final String? title =
          message.notification?.title ?? message.data['title'];
      final String? body = message.notification?.body ?? message.data['body'];
      // final String? tripId = message.data['data']['score'];
      // print('Message received with title: $title,  ');
      // if (message.data.isNotEmpty) {
      //   // Access the data object
      //   Map<String, dynamic> data = message.data;
      //   print(data['tripReqestsId']);
      //   // Process the data as needed
      
      //   sharedPreferences.setString('tripReqestsId', data['tripReqestsId']);
      //   data.forEach((key, value) {
      //     print('$key: $value');
      //   });
      // }
       final AndroidNotificationChannel channel = AndroidNotificationChannel(
        'channel_id',
        'channel_name',
        description:
        'This channel is used for important notifications.', // description

        importance: Importance.high,
        playSound: true,
      );
  
      FlutterLocalNotificationsPlugin()
          .show(0, title ?? '', body ?? '',   NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: '@mipmap/ic_launcher',
        ),
      ),);
      // Handle incoming message
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the app is opened from a notification
      final String? title =
          message.notification?.title ?? message.data['title'];
      final String? body = message.notification?.body ?? message.data['body'];
      final Map<String, dynamic> data = message.data;
      // _showNotificationDetails(title, body, data);
    });
  

  }

  Future<String?> getDeviceToken() {
    return _firebaseMessaging.getToken();
  }


}
