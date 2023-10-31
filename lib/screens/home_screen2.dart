import 'dart:async';

import 'package:driver/components/connection_indicator.dart';
import 'package:driver/components/drawer_menu.dart';
import 'package:driver/components/hamberger_menu.dart';
import 'package:driver/components/map_sheet.dart';
import 'package:driver/controllers/permission_controller.dart';
import 'package:driver/controllers/position_controller.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  String driverName = 'Mesfin';
  String tripStatus = '';
  @override
  void initState() {
    // TODO: implement initState
    getTripStatus();
    super.initState();
  }

  void getTripStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    tripStatus = sharedPreferences.getString('tripStatus') ?? '';
    setState(() {});
    print('tripStatus------$tripStatus');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.60;
    // PositionController positionController = Get.put(PositionController());
    return Scaffold(
      drawer: DrawerMenu(drawerWidth: drawerWidth, driverName: driverName),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Stack(children: [
            MapSheet(),
            HambergerMenu(),
            DashboardV2( tripStatus: tripStatus,)
            // RecenterButton(
            //     controller: _controller,
            //     positionController: positionController),
            // Positioned(
            //     top: 40,
            //     left: 20,
            //     child: Column(
            //       children: [
            //         StreamBuilder<Map<String, dynamic>?>(
            //           stream: FlutterBackgroundService().on('update'),
            //           builder: (context, snapshot) {
            //             if (!snapshot.hasData) {
            //               return const Center(
            //                 child: Text("--------"),
            //               );
            //             }

            //             final data = snapshot.data!;
            //             String? device = data["device"];
            //             DateTime? date =
            //                 DateTime.tryParse(data["current_date"]);
            //             return Column(
            //               children: [
            //                 Text(device ?? 'Unknown'),
            //                 Text(date.toString()),
            //               ],
            //             );
            //           },
            //         ),
            //         StreamBuilder<Map<String, dynamic>?>(
            //           stream: FlutterBackgroundService().on('trip'),
            //           builder: (context, snapshot) {
            //             if (snapshot.hasData) {
            //               final data = snapshot.data!;
            //               tripStatus = data["tripStatus"];
            //               if (tripStatus != "started") {
            //                 return ElevatedButton(
            //                   child: Text("start-timer1"),
            //                   onPressed: () async {
            //                     final service = FlutterBackgroundService();
            //                     var isRunning = await service.isRunning();
            //                     service.invoke("start-timer1");
            //                     setState(() {});
            //                   },
            //                 );
            //               } else {
            //                 return ElevatedButton(
            //                   child: Text("stop-timer1"),
            //                   onPressed: () async {
            //                     final service = FlutterBackgroundService();
            //                     var isRunning = await service.isRunning();
            //                     service.invoke("stop-timer1");
            //                     setState(() {});
            //                   },
            //                 );
            //               }
            //             } else {
            //               //    final data = snapshot.data!;
            //               // tripStatus = data["tripStatus"];
            //               print('tripStatus:===== $tripStatus');
            //               if (tripStatus != "started") {
            //                 return ElevatedButton(
            //                   child: Text("start-timer1"),
            //                   onPressed: () async {
            //                     final service = FlutterBackgroundService();
            //                     var isRunning = await service.isRunning();
            //                     service.invoke("start-timer1");
            //                     setState(() {});
            //                   },
            //                 );
            //               } else {
            //                 return ElevatedButton(
            //                   child: Text("stop-timer1"),
            //                   onPressed: () async {
            //                     final service = FlutterBackgroundService();
            //                     var isRunning = await service.isRunning();
            //                     service.invoke("stop-timer1");
            //                     setState(() {});
            //                   },
            //                 );
            //               }
            //             }

            //             // return Column(
            //             //   children: [
            //             //     Text(device ?? 'Unknown'),
            //             //     Text(date.toString()),
            //             //   ],
            //             // );
            //           },
            //         ),
            //       ],
            //     ))
          
          ]),
        ),
      ),
      bottomSheet: BottomConnectionIndicator(),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  //  _goToTheLake(double latitude, double longitude) async {
  //   final GoogleMapController controller = await _controller.future;
  //   await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(latitude, longitude),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414)));
  // }
}

// class RecenterButton extends StatelessWidget {
//   const RecenterButton({
//     super.key,
//     required Completer<GoogleMapController> controller,
//     // required this.positionController,
//   }) : _controller = controller;

//   final Completer<GoogleMapController> _controller;
//   // final PositionController positionController;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//         bottom: 60,
//         left: 30,
//         child: IconButton(
//           onPressed: () async {
//             final GoogleMapController controller = await _controller.future;
//             await controller.animateCamera(CameraUpdate.newCameraPosition(
//                 CameraPosition(
//                     bearing: 2.8334901395799,
//                     target: LatLng(positionController.latitude,
//                         positionController.longitude),
//                     tilt: 59.440717697143555,
//                     zoom: 17.151926040649414)));
//           },
//           iconSize: 40,
//           icon: Icon(Icons.gps_fixed),
//         ));
//   }
// }

class DashboardV2 extends StatefulWidget {
  final String tripStatus;
  // final VoidCallback function;
  // final PositionController positionController;
  const DashboardV2({
    super.key,
    required this.tripStatus,
    // required this.positionController,
  });

  @override
  State<DashboardV2> createState() => _DashboardV2State();
}

class _DashboardV2State extends State<DashboardV2> {
  bool started = false;

  Future<bool> getTimerStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("started") ?? false;
  }

  @override
  void initState() {
    // TODO: implement initState
    getTimerStatus().then(
      (value) {
        started = value;
      },
    );
    // FirestoreController firestoreController = Get.put(FirestoreController());
    // firestoreController.trackUserPresence();
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Positioned(
        top: 90,
        right: 0,
        left: 0,
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          padding: EdgeInsets.only(left: 10, right: 10, top: 8),
          decoration: BoxDecoration(
            color: Color.fromARGB(
                255, 238, 235, 235), // Set the desired background color
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.2), // Set the shadow color and opacity
                spreadRadius: 2, // Set the spread radius of the shadow
                blurRadius: 5, // Set the blur radius of the shadow
                offset: Offset(0, 2), // Set the offset of the shadow
              ),
            ],
          ),
          child: StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                num? speed = snapshot.data?["speed"] ?? 0;
                num? speed_km = snapshot.data?["speed_km"] ?? 0;
                num? distance = snapshot.data?["distance"] ?? 0;
                num? price = snapshot.data?["price"] ?? 0;
                String? time = snapshot.data?["time"] ?? "00:00:00";

                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StreamBuilder<Map<String, dynamic>?>(
                              stream:
                                  FlutterBackgroundService().on('trip'),
                              builder: (context, snapshot) {
                                String timer_status;
                                if (snapshot.data == null) {
                                  timer_status =widget.tripStatus;
                                } else {
                                  timer_status =
                                      snapshot.data?["tripStatus"] ?? "stoped";
                                     
                                }
                                if (timer_status != "started") {
                                  return OutlinedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .green), // Set the background color
                                        foregroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .white), // Set the text color
                                      ),
                                      onPressed: () {
                                        showStartTripDialog(context)
                                            .then((value) async {
                                          if (value != null && value) {
                                            // User clicked 'Yes', perform the desired action
                                            // Add your code here
                                            final service =
                                                FlutterBackgroundService();
                                            var isRunning =
                                                await service.isRunning();
                                            service.invoke("start-timer1");
                                            setState(() {});
                                            // Get.snackbar('Trip Started', 'Wish you good ride');
                                           
                                          } else {
                                            // User clicked 'No' or pressed outside the dialog
                                            // Add your code here
                                          }
                                        });
                                      },
                                      child: Text("Start New"));
                                } else {
                                  return OutlinedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .red), // Set the background color
                                        foregroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .white), // Set the text color
                                      ),
                                      onPressed: () {
                                        showStopDialog(context)
                                            .then((value) async {
                                          if (value != null && value) {
                                            // User clicked 'Yes', perform the desired action
                                            // Add your code here
                                            final service =
                                                FlutterBackgroundService();
                                            var isRunning =
                                                await service.isRunning();
                                            service.invoke("stop-timer1");
                                            setState(() {});

                                            showTripReportDialog(
                                                context, price, distance, time);
                                          } else {
                                            // User clicked 'No' or pressed outside the dialog
                                            // Add your code here
                                          }
                                        });
                                      },
                                      child: Text("Stop"));
                                }
                              }),
                          Text(
                            "$price Birr",
                            style: TextStyle(
                                fontSize: 28,
                                color: Color.fromARGB(255, 90, 158, 92)),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "${speed_km?.toStringAsFixed(1) ?? ''}",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text("Km/h")
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "${distance?.toStringAsFixed(1) ?? ''}",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text("Km")
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "$time",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text("Waiting")
                            ],
                          ),
                        ],
                      )
                    ]);
              }),
        ));
  }

  Future<dynamic> showStartTripDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('VIP Taxi '),
          content: Text(
            'Confirm start Trip?',
            style: TextStyle(color: Colors.green, fontSize: 15),
          ),
          actions: [
            OutlinedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when 'No' is pressed
              },
            ),
            OutlinedButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when 'Yes' is pressed
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> showTripReportDialog(
      BuildContext context, num? price, num? distance, String? time) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('VIP Taxi'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Trip Report ",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Price: ",
                      style: TextStyle(color: Colors.green, fontSize: 20),
                    ),
                    Text("$price Birr",
                        style: TextStyle(color: Colors.green, fontSize: 20))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Distance: ",
                        style: TextStyle(color: Colors.green, fontSize: 20)),
                    Text("${distance?.toStringAsFixed(2) ?? ''}Km",
                        style: TextStyle(color: Colors.green, fontSize: 20))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Waiting time: ",
                        style: TextStyle(color: Colors.green, fontSize: 20)),
                    Text("$time ",
                        style: TextStyle(color: Colors.green, fontSize: 20))
                  ],
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              child: Text('Close'),
              onPressed: () {
                print("close button");
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> showStopDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('VIP Taxi '),
          content: Text(
            'Are you sure you want to stop the trip?',
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            OutlinedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when 'No' is pressed
              },
            ),
            OutlinedButton(
              child: Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when 'Yes' is pressed
              },
            ),
          ],
        );
      },
    );
  }
}