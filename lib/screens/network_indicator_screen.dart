import 'package:driver/controllers/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkIndicatorScreen extends StatefulWidget {
  @override
  State<NetworkIndicatorScreen> createState() => _NetworkIndicatorScreenState();
}

class _NetworkIndicatorScreenState extends State<NetworkIndicatorScreen> {
  NetworkController networkController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    // ever(networkController.isNetworkUsable, (value) {
    //   if (value) {
    //     Get.back();
    //   }
    // });
    networkController.isNetworkUsable.listen(
      (value) {
        // Perform actions based on the updated network status
        print(value);
        if (value) {
          // Network is usable, perform online tasks
          Get.back();
        } else {
          // Network is not usable, handle offline scenarios
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if (shouldPop) {
        //   // Allow page navigation when the condition is met
        //   return true;
        // } else {
        //   // Disable page navigation by returning false
        //   return false;
        // }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Network indicator'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Set the condition to enable navigation
                  // shouldPop = true;
                  // Pop the current page
                  // Navigator.pop(context);
                },
                child: Text('Pop Page'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
