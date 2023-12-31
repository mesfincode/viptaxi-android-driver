import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver/components/bottom_sheet_comp.dart';
import 'package:driver/components/bottom_sheet_compV2.dart';
import 'package:driver/components/connection_indicator.dart';
import 'package:driver/components/custom_switch.dart';
import 'package:driver/components/drawer_menu.dart';
import 'package:driver/components/hamberger_menu.dart';
import 'package:driver/components/map_sheet.dart';
import 'package:driver/components/trip_request.dart';
import 'package:driver/components/widgets/NetworkIndicatorWidget.dart';
import 'package:driver/constants.dart';
import 'package:driver/controllers/network_controller.dart';
import 'package:driver/controllers/permission_controller.dart';
import 'package:driver/controllers/position_controller.dart';
import 'package:driver/controllers/trip_controller.dart';
import 'package:driver/main.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  DatabaseReference driverRef = FirebaseDatabase.instance.ref('drivers');

  String driverName = 'Mesfin';
  String tripStatus = '';
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isNetworkUsable = true;
  @override
  void initState() {
    // TODO: implement initState
    initialize();
    getTripStatus();
    getOnlineStatus();

    super.initState();
  }

  void getOnlineStatus() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';
    driverRef
        .child('/${driverId}/presence')
        .onValue
        .listen((DatabaseEvent event) {
      dynamic data = event.snapshot.value;
      if (data != null) {
        dynamic status = data['status'];
        if (status == "online") {
          setState(() {
            _isOnline = true;
          });
        } else {
          setState(() {
            _isOnline = false;
          });
        }
      }
    });
  }

  void setOffline() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/presence').update({
      "status": "offline",
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      // Data saved successfully!
      sharedPref.setBool(WANT_TO_BE_ONLINE, false);
      setState(() {
        _isOnline = false;
      });
      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  void setOnline() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/presence').update({
      "status": "online",
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      // Data saved successfully!
      sharedPref.setBool(WANT_TO_BE_ONLINE, true);
      setState(() {
        _isOnline = true;
      });
      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  void initialize() async {
    await Permission.notification.isDenied.then(
      (value) {
        if (value) {
          Permission.notification.request();
        }
      },
    );
    WakelockPlus.enable();
  }

  void getTripStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    tripStatus = sharedPreferences.getString('tripStatus') ?? '';
    setState(() {});
    print('tripStatus------$tripStatus');
  }

  bool _isOnline = false;

  void _toggleStatus() {
    // setOffline() ;
    if (_isOnline) {
      setOffline();
    } else {
      setOnline();
    }
    // setState(() {
    //   _isOnline = !_isOnline;
    // });
  }

  @override
  Widget build(BuildContext context) {
 
  
    NetworkController networkController = Get.find();
    return Scaffold(
      drawer: DrawerMenu(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Stack(children: [
            MapSheet(),
            NetworkIndicatorWidget(networkController: networkController),
            HambergerMenu(),
            DashboardV2(),
            Positioned(
                bottom: MediaQuery.of(context).size.height * 0.6,
                left: 30,
                child: InkWell(
                  onTap: _toggleStatus,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: _isOnline ? Colors.green : Colors.red,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isOnline ? Icons.check : Icons.close,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                      )
           
          ]),
        ),
      ),
      bottomSheet: BottomSheetComponentV2(),
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
  // final String tripStatus;
  // final VoidCallback function;
  // final PositionController positionController;
  const DashboardV2({
    super.key,
    // required this.tripStatus,
    // required this.positionController,
  });

  @override
  State<DashboardV2> createState() => _DashboardV2State();
}

class _DashboardV2State extends State<DashboardV2> {
  bool started = false;
  DatabaseReference ref = FirebaseDatabase.instance.ref('drivers');
  final storage = new FlutterSecureStorage();

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
    TripController tripController = Get.put(TripController());

    return Positioned(
        top: 90,
        right: 0,
        left: 0,
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          padding: EdgeInsets.only(left: 10, right: 10, top: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 255, 255, 255), // Set the desired background color
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
                // num? speed = snapshot.data?["speed"] ?? 0;
                num speed_km = snapshot.data?["speed_km"] ?? 0;
                num distance = snapshot.data?["distance"] ?? 0;
                num price = snapshot.data?["price"] ?? 0;
                String time = snapshot.data?["time"] ?? "00:00:00";

                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                            if (tripController.isLoading) {
                              return CircularProgressIndicator();
                            } else {
                              return StreamBuilder<Map<String, dynamic>?>(
                                  stream: FlutterBackgroundService().on('trip'),
                                  builder: (context, snapshot) {
                                    String timer_status = '';
                                    if (snapshot.data == null) {
                                      timer_status = tripController.tripStatus;
                                    } else {
                                      timer_status =
                                          snapshot.data?["tripStatus"] ??
                                              "stoped";
                                    }
                                    if (timer_status != "started") {
                                      return Container();
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
                                                // final service =
                                                //     FlutterBackgroundService();
                                                // var isRunning =
                                                //     await service.isRunning();
                                                tripController.stopTrip(context,
                                                    price, distance, time);

                                                // setState(() {});
                                              } else {
                                                // User clicked 'No' or pressed outside the dialog
                                                // Add your code here
                                              }
                                            });
                                          },
                                          child: Text("Stop"));
                                    }
                                  });
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

  void showDiaalog(num? price, num? distance, String? time) {
    Get.defaultDialog(
      title: "Vip taxi trip report",
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Text(
            //   "Trip Report ",
            //   style: TextStyle(color: Colors.black, fontSize: 20),
            // ),
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
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // Perform action when the dialog button is pressed
            Get.back();
          },
          child: Text("OK"),
        ),
      ],
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
