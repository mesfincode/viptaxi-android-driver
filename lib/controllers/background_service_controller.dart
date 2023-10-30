import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:driver/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:driver/services/background_service.dart';

class BackgroundServiceController extends GetxController
    with WidgetsBindingObserver {
  Timer? _timer1;
  Timer? _timer2;

  Position? _previousPosition;
  String? _currentAddress;
  Position? _currentPosition;
  double _distance = 0.0;
// double _speed = 0.0;
  double _speed_km = 0.0;
  int _price = 0;
  Geodesy _geodesy = Geodesy();

  int dayInitialPrice = 200;
  int nightInitialPrice = 300;

  int dayPerMiniutePrice = 5;
  int nightPerMinutePrice = 8;

  int dayKilloMeterPrice = 80;
  int nightKilloMeterPrice = 120;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Implement your logic here when the app resumes
      print('background-service-conteroller ----app resumed');
      // checkLocationServiceEnabled();
      // requestLocationPermission();
    }
  }

  void startTimer1(ServiceInstance service) async {
    Get.put(ProfileController());
    RequestController requestController = Get.put(RequestController());
    bool tripCreatedOnServer = await requestController.startTripRequest(
        {'latitude': '5555', 'longitude': '9898', 'geohash': 'aksjff'});
    if (!tripCreatedOnServer) {
      print('trip created on the server continue');
    } else {
      print('trip not created on the server');
      return;
    }
    const duration = Duration(
        seconds:
            1); // Set the duration of the timer (5 seconds in this example)

    if (_timer1 == null) {
      _timer1 = Timer.periodic(duration, (Timer timer) async {
        print('timer---1 E: ${DateTime.now()}');

        // test using external plugin
        final deviceInfo = DeviceInfoPlugin();
        String? device;
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          device = androidInfo.model;
        }

        if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          device = iosInfo.model;
        }

        service.invoke(
          'update',
          {
            "current_date": DateTime.now().toIso8601String(),
            "device": device,
          },
        );
        // Do something when the timer expires
      });
    }
  }

  void stopTimer1() {
    if (_timer1 != null) {
      _timer1?.cancel(); // Cancel the timer if it's running
      _timer1 = null; // Set the timer instance to null
    }
  }

  void startTimer2(ServiceInstance service) {
    const duration = Duration(
        seconds:
            1); // Set the duration of the timer (5 seconds in this example)

    if (_timer2 == null) {
      _timer2 = Timer.periodic(duration, (Timer timer) async {
        print('timer---2 E: ${DateTime.now()}');

        // test using external plugin
        final deviceInfo = DeviceInfoPlugin();
        String? device;
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          device = androidInfo.model;
        }

        if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          device = iosInfo.model;
        }

        service.invoke(
          'update2',
          {
            "current_date2": DateTime.now().toIso8601String(),
            "device2": device,
          },
        );
        // Do something when the timer expires
      });
    }
  }

  void stopTimer2() {
    if (_timer2 != null) {
      _timer2?.cancel(); // Cancel the timer if it's running
      _timer2 = null; // Set the timer instance to null
    }
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
}
