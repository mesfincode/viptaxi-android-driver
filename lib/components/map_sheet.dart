import 'dart:async';

import 'package:driver/controllers/position_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapSheet extends StatefulWidget {
  @override
  State<MapSheet> createState() => _MapSheetState();
}

class _MapSheetState extends State<MapSheet> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  @override
  void initState() {
    // TODO: implement initState
    getTimerStatus().then(
      (value) {
        started = value;
      },
    );
    _getCurrentPosition();
    // _startTimer();
    // getDriver();
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      setState(() => {
            _currentPosition = position,
            _mapController?.animateCamera(CameraUpdate.newLatLng(
                LatLng(position!.latitude, position!.longitude)))
          });
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}, ${position.speed.toString()}');
    });
    super.initState();
  }

  //  void getDriver() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   driverName = (await sharedPreferences.getString("driverName"))!;
  // }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    // _cancelTimer();
    super.dispose();
  }

  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();

  GoogleMapController? _mapController;
  double lati = 8.9891196;
  double longi = 38.770571;
  Position? _currentPosition;
  CameraPosition? _cameraPosition;
  String driverName = '';
  late Timer _timer;
  // int _counter = 0;
  bool started = false;


  // void _cancelTimer() {
  //   // Cancel the timer if it is active
  //   _timer?.cancel();
  // }

  Future<bool> getTimerStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("started") ?? false;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => {
            _currentPosition = position,
            // _speed = position.speed,
            // _speed_km = position.speed * 3.6
            // _goToTheLake(position.latitude, position.longitude)
            _mapController?.animateCamera(CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude)))
          });
      // _getAddressFromLatLng(_currentPosition!);
      // _calculateDistance(position);
      // print('position'+position.toString() + ' speed: ' + position.speed.toString() + ' distance: ' + _distance.toString());
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void updateCarPositions() {
    setState(() {
      // Simulate updating car positions (replace with your actual implementation)
      // Here, we randomly update the latitude and longitude by a small amount
      lati = lati + 0.0001;
      longi = longi + 0.0001;
      _mapController
          ?.animateCamera(CameraUpdate.newLatLng(LatLng(lati, longi)));
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // PositionController positionController = Get.find();
    // return Obx(() {
    //   if (positionController.latitude == 0.0 ||
    //       positionController.longitude == 0.0) {
    //     return CircularProgressIndicator();
    //   } else {
    if (_currentPosition != null) {
      return Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                bearing: 2.8334901395799,
                target:
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                tilt: 30.440717697143555,
                zoom: 16.151926040649414),
            markers: {
              Marker(
                markerId: MarkerId('current_position'),
                position:
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                // icon: markerIcon
              )
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            compassEnabled: false,
             rotateGesturesEnabled: false, 
          ),

           Positioned(
        bottom: 60,
        left: 30,
        child: IconButton(
          onPressed: () async {
            final GoogleMapController controller = await _controller.future;
            await controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    bearing: 2.8334901395799,
                    target: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    tilt: 30.440717697143555,
                    zoom: 16.151926040649414)));
          },
          iconSize: 40,
          icon: Icon(Icons.gps_fixed),
        ))
        ],
      );
    } else {
      return CircularProgressIndicator();
    }
    //   }
    // });
  }
}
