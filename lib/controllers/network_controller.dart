import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NetworkController extends GetxController with WidgetsBindingObserver {
  var _isNetworkUsable =true.obs;
  bool get isNetworkUsable => _isNetworkUsable.value;
 ConnectivityResult _connectivityResult = ConnectivityResult.none;
  
  @override
  void onInit() {
    super.onInit();
            WidgetsBinding.instance!.addObserver(this);
             hasUsableNetwork();
   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
   
        _connectivityResult = result;
        // checkNetworkUsability();
        hasUsableNetwork();
     
    });
  
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
      hasUsableNetwork();
    }
  }

   Future<bool> hasUsableNetwork() async {
    try {
      print("checking network ---");
      //  final response = await InternetAddress.lookup('google.com');
      // if (response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
      //   // Internet is accessible
      //   _isNetworkUsable.value = true;

      //   print('Internet is accessible.');
      //   return true;
      // } else {
      //   // Internet is not accessible
      //   _isNetworkUsable.value = false;

      //   print('Internet is not accessible.');
      //   return false;
      // }
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        print("network good");
         _isNetworkUsable.value = true;
        return true;
      } else {
         print("network bad");
         _isNetworkUsable.value = false;
        return false;
      }
    } catch (error) {
               print("network err $error");

       _isNetworkUsable.value = false;
      return false;
    }
  }

  void checkNetworkUsability() async {

     print("Check network usablity $_connectivityResult") ;

   
    if (_connectivityResult == ConnectivityResult.wifi ||
        _connectivityResult == ConnectivityResult.mobile) {
      final networkUsablity = await hasUsableNetwork();
    print("--net usablity $networkUsablity");
        _isNetworkUsable.value = networkUsablity;
     
    } else {
     
        _isNetworkUsable.value = false;
  
    }
  }

}
