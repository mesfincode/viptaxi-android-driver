import 'package:driver/controllers/background_service_controller.dart';
import 'package:driver/controllers/permission_controller.dart';
import 'package:driver/controllers/position_controller.dart';
import 'package:driver/controllers/profile_controller.dart';
import 'package:driver/firebase_options.dart';
import 'package:driver/services/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:driver/screens/splash_screen.dart';
import 'package:driver/services/background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'controllers/network_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

        FirebaseMessagingService().initialize();

  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        initialBinding: BindingsBuilder(() {
          Get.lazyPut<NetworkController>(() => NetworkController());
          Get.put(ProfileController());
          Get.put(BackgroundServiceController());
          // Get.put(PermissionController());
        }),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen());
  }
}
