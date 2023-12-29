import 'package:driver/controllers/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkIndicatorWidget extends StatelessWidget {
  const NetworkIndicatorWidget({
    super.key,
    required this.networkController,
  });

  final NetworkController networkController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!networkController.isNetworkUsable.value) {
        return Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Container(
              // width: double.infinity,
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.red),

              // padding: EdgeInsets.all(5),
              child: Center(
                child: Text(
                  "Network unavailable",
                  style: TextStyle(color: Colors.white),
                ),
                // OutlinedButton(onPressed: (){
                //  networkController.hasUsableNetwork();
                // }, child: Text("Retry"))
              ),
            ));
      } else {
        return Text("");
      }
    });
  }
}