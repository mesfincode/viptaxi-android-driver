import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity/connectivity.dart';

class NetworkController extends GetxController with WidgetsBindingObserver {
  var _connectionStatus =false.obs;
  bool get connectionStatus => _connectionStatus.value;

  @override
  void onInit() {
    super.onInit();
            WidgetsBinding.instance!.addObserver(this);

    checkConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectivity();
    });
  }
@override
  void onClose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed---');
      checkConnectivity();
    }
  }
  void checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || (connectivityResult == ConnectivityResult.wifi)) {
      _connectionStatus.value = true;
         print("++++++++++++network connected");
 
    } else {
      _connectionStatus.value = false;
           

    }
  }
}
