import 'dart:async';
import 'dart:io';

import 'package:dart_geohash/dart_geohash.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:driver/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:driver/services/background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String waitingTime = '';
  int _price = 0;
  Geodesy _geodesy = Geodesy();

  int dayInitialPrice = 200;
  int nightInitialPrice = 300;

  int dayPerMiniutePrice = 5;
  int nightPerMinutePrice = 8;

  int dayKilloMeterPrice = 80;
  int nightKilloMeterPrice = 120;
  final storage = new FlutterSecureStorage();
  String? tripStatus;

  int seconds = 0, miniuts = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    getTripStatus();
    _getCurrentPosition();
    startTrackingLocation();
  }

  void getTripStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    tripStatus = sharedPreferences.getString('tripStatus');
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
      getTripStatus();
      _getCurrentPosition();
      startTrackingLocation();
    }
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _currentPosition = position;
      // _getAddressFromLatLng(_currentPosition!);
      // _calculateDistance(position);
      // print('position'+position.toString() + ' speed: ' + position.speed.toString() + ' distance: ' + _distance.toString());
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void startTimer1(ServiceInstance service) async {
    _getCurrentPosition();
      startTrackingLocation();

    DateTime _startTime;
    //  stopTimer1(service);
    if (_timer1 == null) {
      seconds = 0;
      miniuts = 0;
      hours = 0;
      digitSeconds = "00";
      digitHours = "00";
      digitMinutes = "00";
      // _timer = null;
      String time = "$digitHours:$digitMinutes:$digitSeconds";
      _price = 0;
      print("starting _timer----");

      _startTime = DateTime.now();
      final now = DateTime.now();
      final isDay = isTimeBetween(
          now, TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 19, minute: 0));
      _timer1 = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
        print('timer---1 E: ${DateTime.now()}');

        int localSeconds = seconds;
        print("speedKM: " + _speed_km.toString());
        if (_speed_km < 2) {
          localSeconds = seconds + 2;
        }
        int localMinutes = miniuts;
        int localHours = hours;

        if (localSeconds > 59) {
          if (localMinutes > 59) {
            localHours++;
            localMinutes = 0;
          } else {
            localMinutes++;
            localSeconds = 0;
          }
        }
        seconds = localSeconds;
        miniuts = localMinutes;
        hours = localHours;

        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitHours = (hours >= 10) ? "$hours" : "0$hours";
        digitMinutes = (miniuts >= 10) ? "$miniuts" : "0$miniuts";
        String time = "$digitHours:$digitMinutes:$digitSeconds";

        // final actualTime = currentTime.difference(_startTime).inMilliseconds;

        // print('FLUTTER BACKGROUND SERVICE: ${_formatTime(actualTime)}');
        waitingTime = time;
        processLocation(service, time, hours, miniuts, isDay);
        // Do something when the timer expires
      });

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('tripStatus', 'started');
      service.invoke(
        'trip',
        {"tripStatus": "started"},
      );
    }
  }

  void processLocation(ServiceInstance service, String time, int hours,
      int minutes, bool isDay) async {
    print("proces locatin----");

    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((Position position) {
      // setState(() => {
      GeoHasher geoHasher = GeoHasher();
      String hash = geoHasher.encode(
          position.latitude, position.longitude); // Returns a string geohash
      print("geohash--------" + hash);
      _currentPosition = position;

      // _speed = position.speed;
      _speed_km = position.speed * 3.6;
      if (_speed_km < 2) {
        // _speed=0.0;
        _speed_km = 0.0;
      }
      print(_currentPosition);
      // print(_speed);
      print(_speed_km);
      if (_previousPosition != null) {
        LatLng latLng1 =
            LatLng(_previousPosition!.latitude, _previousPosition!.longitude);
        LatLng latLng2 = LatLng(position!.latitude, position!.longitude);
        num distance = _geodesy.distanceBetweenTwoGeoPoints(latLng1, latLng2);

        if (distance >= 2 && _speed_km > 2) {
          _distance += distance / 1000;
        }
      }
      _previousPosition = position;
    }).catchError((e) {
      debugPrint(e);
    });

    if (isDay) {
      print('*Day*');
      double priceCalculation = dayInitialPrice +
          (_distance * dayKilloMeterPrice) +
          (hours * 60 * dayPerMiniutePrice) +
          (minutes * dayPerMiniutePrice);
      _price = priceCalculation.toInt();
    } else {
      print('*Night*');

      double priceCalculation = nightInitialPrice +
          (_distance * nightKilloMeterPrice) +
          (hours * 60 * nightPerMinutePrice) +
          (minutes * nightPerMinutePrice);
      _price = priceCalculation.toInt();
    }

    print("distanceaa: $_distance");
    service.invoke(
      'update',
      {
        // "speed": _speed,
        "speed_km": _speed_km,
        "distance": _distance,
        "time": time,
        "price": _price,
        "latutude": _currentPosition?.latitude,
        "longtude": _currentPosition?.longitude,
      },
    );
  }

  bool isTimeBetween(
      DateTime dateTime, TimeOfDay startTime, TimeOfDay endTime) {
    final time = TimeOfDay.fromDateTime(dateTime);
    final startDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        startTime.hour, startTime.minute);
    final endDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        endTime.hour, endTime.minute);

    final dateTimeInTimeRange =
        dateTime.isAfter(startDateTime) && dateTime.isBefore(endDateTime);

    return dateTimeInTimeRange;
  }

  void startTrackingLocation() {
    _handleLocationPermission().then((value) => {
          if (value)
            {
              Geolocator.getPositionStream(
                  locationSettings: LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 100,
              )).listen((Position? position) {
                print(position == null
                    ? 'Unknown'
                    : '${position.latitude.toString()}, ${position.longitude.toString()}, ${position.speed.toString()}');
              })
            }
        });
  }

  void stopTimer1(ServiceInstance service) async {
    if (_timer1 != null) {
      _timer1?.cancel(); // Cancel the timer if it's running
      _timer1 = null; // Set the timer instance to null

      seconds = 0;
      miniuts = 0;
      hours = 0;
      digitSeconds = "00";
      digitHours = "00";
      digitMinutes = "00";

      _distance = 0.0;

      _price = 0;
    }
       SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('tripStatus', 'stoped');
    service.invoke(
      'trip',
      {"tripStatus": "stoped"},
    );
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
