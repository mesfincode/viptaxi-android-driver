import 'package:driver/components/create_onstreet_trip_comp.dart';
import 'package:driver/components/drawer_menu.dart';
import 'package:driver/components/hamberger_menu.dart';
import 'package:driver/components/map_sheet.dart';
import 'package:driver/components/widgets/NetworkIndicatorWidget.dart';
import 'package:driver/components/widgets/OnlineIndicatorWidget.dart';
import 'package:driver/controllers/network_controller.dart';
import 'package:driver/controllers/new_trip_request_controller.dart';
import 'package:driver/controllers/trip_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen3 extends StatefulWidget {
  const HomeScreen3({super.key});

  @override
  State<HomeScreen3> createState() => _HomeScreen3State();
}

class _HomeScreen3State extends State<HomeScreen3> {
  @override
  void initState() {
    // TODO: implement initState
 NewTripRequestController newTripRequestController = Get.put(NewTripRequestController());

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    NetworkController networkController = Get.find();
        TripController tripController = Get.put(TripController());

    return Scaffold(
      drawer: DrawerMenu(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Stack(children: [
            MapSheet(),
            NetworkIndicatorWidget(networkController: networkController),
            HambergerMenu(),
            OnlineIndicatorWidget(),
            CreateOnStreetTrip()
          ]),
        ),
      ),
    );
  }
}
