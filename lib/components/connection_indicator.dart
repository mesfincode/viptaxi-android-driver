// import 'dart:async';

// import 'package:connectivity/connectivity.dart';
// import 'package:flutter/material.dart';
// import 'package:driver/controllers/network_controller.dart';
// import 'package:get/get.dart';

// class BottomConnectionIndicator extends StatefulWidget {
//   @override
//   _BottomConnectionIndicatorState createState() =>
//       _BottomConnectionIndicatorState();
// }

// class _BottomConnectionIndicatorState extends State<BottomConnectionIndicator> {
//   bool _isConnected = true;

//   // StreamSubscription? _connectionChangeStream;

//   @override
//   void initState() {
//     super.initState();
//     // _connectionChangeStream =
//     //     Connectivity().onConnectivityChanged.listen((isConnected) {
//     //   setState(() {
//     //     _isConnected = isConnected;
//     //   });
//     // });
//   }

//   @override
//   void dispose() {
//     // _connectionChangeStream?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//        NetworkController networkController = Get.put(NetworkController()); 

//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       height: networkController.connectionStatus ? 0 : kToolbarHeight,
//       child: Material(
//         elevation: 3,
//         child: Obx(() {
//           if(!networkController.connectionStatus){
//             return Container(
//               margin: EdgeInsets.zero,
//           color: Colors.black,
//           child: Padding(
//             padding: const EdgeInsets.only( left:15.0,right: 15.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Connecting...',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.normal,
//                     fontSize: 17
//                   ),
//                 ),
//                 SizedBox(width: 4),
              
//                   CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     strokeWidth: 1,
//                   ),
//               ],
//             ),
//           )
              
//         );
//           }else{
//             return Visibility(
//                 visible: false,
//                 child: Container(),
//               );
//           }
//         })
//       ),
//     );
//   }
// }