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

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {

  String driverName = 'Mesfin';

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
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
            // RecenterButton(
            //     controller: _controller,
            //     positionController: positionController),
            Positioned(
              top: 40,
              left: 20,
                child: Column(
              children: [
                StreamBuilder<Map<String, dynamic>?>(
                  stream: FlutterBackgroundService().on('update'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final data = snapshot.data!;
                    String? device = data["device"];
                    DateTime? date = DateTime.tryParse(data["current_date"]);
                    return Column(
                      children: [
                        Text(device ?? 'Unknown'),
                        Text(date.toString()),
                      ],
                    );
                  },
                ),
                ElevatedButton(
                  child: Text("start-timer1"),
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    service.invoke("start-timer1");
                    setState(() {});
                  },
                ),
              ],
            ))
          
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
