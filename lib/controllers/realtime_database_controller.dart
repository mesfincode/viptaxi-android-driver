import 'package:driver/constants.dart';
import 'package:driver/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RealtimeDatabaseController extends GetxController
    with WidgetsBindingObserver {
  final DatabaseReference _presenceRef =
      FirebaseDatabase.instance.ref().child('drivers');
  String driverId = '';
  bool driver_presence_choice = false;
  @override
  void onInit() async {
    super.onInit();
    WidgetsBinding.instance!.addObserver(this);
    driver_presence_choice = sharedPref.getBool(WANT_TO_BE_ONLINE) ?? true;
    driverId = await secureStorage.read(key: 'driverId') ?? '';
    trackUserPresence();
  }

  @override
  void onClose() {
    WidgetsBinding.instance!.removeObserver(this);

    // checkNetworkUsability();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed---');
      // checkNetworkUsability();
      trackUserPresence();
    }
  }

  Future<void> trackUserPresence() async {
    if (driverId.isEmpty) {
      return;
    }
    DatabaseReference userPresenceRef =
        _presenceRef.child(driverId).child('presence');

    // Set presence status to "online" and update last seen timestamp when connection is established
    DatabaseReference connectedRef =
        FirebaseDatabase.instance.ref().child('.info/connected');
    connectedRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        if (driver_presence_choice) {
          userPresenceRef.set({
            'status': 'online',
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }
    });

    // Update presence status to "offline" and last seen timestamp when connection is lost
    userPresenceRef.onDisconnect().set({
      'status': 'offline',
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    });
  }

}
