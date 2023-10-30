import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController with WidgetsBindingObserver {
  // Observables
  final _locationPermissionGranted = false.obs;
  final _locationServiceEnabled = false.obs;

  // Getters
  bool get locationPermissionGranted => _locationPermissionGranted.value;
  bool get locationServiceEnabled => _locationServiceEnabled.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance!.addObserver(this);

    checkLocationServiceEnabled();
    requestLocationPermission();
  }

  @override
  void onClose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Implement your logic here when the app resumes
      print('App resumed');
      checkLocationServiceEnabled();
      requestLocationPermission();
    }
  }

  // Methods
  Future<void> requestLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.whileInUse) {
      //  final info = await PackageInfo.fromPlatform();
      // showLocationPermissionDialog(
      //     "Allow location permission to use the application");
      permission = await Geolocator.requestPermission();
    } else {
      _locationPermissionGranted.value = true;
    }


  }

  Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> checkLocationServiceEnabled() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // final location = Location();
    if (!serviceEnabled) {
      showDialogBox("Please enable Location Service");
      // Get.snackbar("location desabled", "dont do this");
    }
    _locationServiceEnabled.value = serviceEnabled;

    return serviceEnabled;
  }

  void showDialogBox(String message) {
    if (Get.isDialogOpen != null && !Get.isDialogOpen!) {
      Get.dialog(
        AlertDialog(
          title: Text('Vip Taxi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: Text('Cancle'),
            ),
            TextButton(
              onPressed: () {
                openLocationSettings();
                // checkLocationServiceEnabled();
                Get.back();
              },
              child: Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  void showLocationPermissionDialog(String message) {
    if (Get.isDialogOpen != null && !Get.isDialogOpen!) {
      Get.dialog(
        AlertDialog(
          title: Text('Vip Taxi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: Text('Cancle'),
            ),
            TextButton(
              onPressed: () async {
                await openAppSettings();
                //  requestLocationPermission();
                Get.back();
              },
              child: Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  void openLocationSettings() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      // Location service is already enabled
      print('Location service is already enabled');
    } else {
      // Location service is not enabled, open settings page
      if (await Geolocator.openLocationSettings()) {
        // User opened the settings page
        print('User opened the location settings page');
      } else {
        // User cancelled or an error occurred
        print('Failed to open the location settings page');
      }
    }
  }
}
