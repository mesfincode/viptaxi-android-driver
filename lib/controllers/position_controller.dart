// import 'dart:async';

// import 'package:geolocator/geolocator.dart';
// import 'package:get/get_rx/get_rx.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';

// class PositionController extends GetxController {
//   RxDouble _latitude = 0.0.obs;
//   double get latitude => _latitude.value;
//   set latitude(double value) => _latitude.value = value;

//   RxDouble _longitude = 0.0.obs;
//   double get longitude => _longitude.value;
//   set longitude(double value) => _longitude.value = value;
//  StreamSubscription<Position>? positionStream;
//   GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
//   Timer? positionTimer;
//   @override
//   void onInit() async {
//     //  initializeService();
//     getCurrentPosition();
//     // startUpdatingPosition();
//     super.onInit();
//   }

//   void startUpdatingPosition() {
//     final LocationSettings locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.bestForNavigation,
//       distanceFilter: 100,
//     );
//   positionStream  =
//         Geolocator.getPositionStream(locationSettings: locationSettings)
//             .listen((Position? position) {
//       _longitude.value = position!.longitude;
//       _latitude.value = position.latitude;
//     });
//   }
//     @override
//   void onClose() {
//     positionStream?.cancel();
//     super.onClose();
//   }
// void getCurrentPosition()async{
//     try {
//            final hasPermission = await _handleLocationPermission();

//       if (!hasPermission) return;
//         Position position = await geolocator.getCurrentPosition();
//         print(position.latitude);
//         print(position.longitude);
//         print(position.speed);

//         _latitude.value = position.latitude;
//         _longitude.value = position.longitude;
//       } catch (e) {
//         print(e);
//       }
// }
//   Future<bool> _handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       //     content: Text(
//       //         'Location services are disabled. Please enable the services')));
//       return false;
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       return false;
//     }
//     if (permission == LocationPermission.deniedForever) {
//       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       //     content: Text(
//       //         'Location permissions are permanently denied, we cannot request permissions.')));
//       return false;
//     }
//     return true;
//   }
// }
