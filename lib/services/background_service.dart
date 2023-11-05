import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/instance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:driver/controllers/background_service_controller.dart';
Timer? _timer1;
Timer? _timer2;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Vip Taxi',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}


@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();



  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  
  // Only available for flutter 3.0.0 and later
  print("starting background service");
  DartPluginRegistrant.ensureInitialized();
BackgroundServiceController backgroundServiceController = Get.put(BackgroundServiceController());
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    print("stop service");
    service.stopSelf();
  });

  service.on('start-timer1').listen((event) {
    print("starting  timer 1");
    // startTimer1(service);
    backgroundServiceController.startTimer1(service);
    // service.stopSelf();
  });

    service.on('stop-timer1').listen((event) {
    print("stoping  timer 1");
       backgroundServiceController.stopTimer1(service);

    // service.stopSelf();
  });
  // bring to foreground

 service.on('start-timer2').listen((event) {
    print("starting  timer 2");
    // startTimer1(service);
    backgroundServiceController.startTimer2(service);
    // service.stopSelf();
  });

    service.on('stop-timer2').listen((event) {
    print("stoping  timer 2");
       backgroundServiceController.stopTimer2();

    // service.stopSelf();
  });
  

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
        title: "VIP TAXI",
        content: "vip taxi is running",
      );
    }
  }
  startTrackingLocation();
  
}

  void startTrackingLocation() async{
       final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
          Geolocator.getPositionStream(
                  locationSettings: LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 100,
              )).listen((Position? position) {
                print(position == null
                    ? 'Unknown'
                    : '${position.latitude.toString()}, ${position.longitude.toString()}, ${position.speed.toString()}');
              });
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

