import 'package:driver/controllers/request_controller.dart';
import 'package:driver/models/TripRequestDetail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripController extends GetxController {
  final service = FlutterBackgroundService();

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _tripStatus = ''.obs;
  String get tripStatus => _tripStatus.value;

  RequestController requestController = Get.put(RequestController());
  DatabaseReference driverRef = FirebaseDatabase.instance.ref('drivers');
  final storage = new FlutterSecureStorage();

  @override
  void onInit() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _tripStatus.value = await sharedPreferences.getString('tripStatus') ?? '';
    super.onInit();
  }

  Future<bool> updateTripStatusOnServer(String requestId, String statusType) async {
    // String driverId = await storage.read(key: 'driverId') ?? '';
    bool tripAcceptedOnServer =
        await requestController.updateTripStatus(requestId, statusType);
    if (tripAcceptedOnServer) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> startTrip(TripRequestDetail tripRequestDetail) async {
    print('trip controller');

    _isLoading.value = true;
    bool tripCreatedOnServer;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String latitude = sharedPreferences.getString('currentLatitude') ?? '--';
    String longitude = sharedPreferences.getString('currentLongitude') ?? '--';

    tripCreatedOnServer = await requestController.startTripRequest(
        {'latitude': latitude, 'longitude': longitude, 'geohash': 'aksjff'},
        tripRequestDetail.riderName!,
        tripRequestDetail.riderPhone!,
        tripRequestDetail.riderPickUpAddress!,
        tripRequestDetail.riderDestinatinoAddress!);
    if (tripCreatedOnServer) {
      print('trip created on the server continue');
      service.invoke("start-timer1");
      _isLoading.value = false;
      _tripStatus.value = "started";
      print('Trip created on the server');
      String driverId = await storage.read(key: 'driverId') ?? '';

      driverRef.child('/${driverId}/tripRequest/requestDetail').update({
        "status": "started",
      }).then((_) {
        // Data saved successfully!

        print("update success");
      }).catchError((error) {
        // The write failed...
        print("update error");
      });
      Get.snackbar(
        "Vip Taxi",
        "Trip Started",
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add_alert),
        snackPosition: SnackPosition.TOP,
      );
    } else {
      print('Trip could not be created on the server');
      _isLoading.value = false;
      // _tripStatus.value = false;
      return;
    }
  }

  stopTrip(BuildContext context, num price, num distance, String time) async {
    _isLoading.value = true;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String tripId = await sharedPreferences.getString('tripId') ?? '';
    String latitude = sharedPreferences.getString('currentLatitude') ?? '--';
    String longitude = sharedPreferences.getString('currentLongitude') ?? '--';
    RequestController requestController = Get.put(RequestController());
    bool tripStopedOnTheServer = await requestController.stopTripRequest(
        tripId,
        {'latitude': latitude, 'longitude': longitude, 'geohash': 'aksjff'},
        double.parse(distance.toStringAsFixed(1)),
        price.toInt(),
        time);
    if (tripStopedOnTheServer) {
      print('Trip stoped on the server');
      //  Get.snackbar(
      //     "app",
      //     "Trip stoped on the server",
      //     icon: Icon(Icons.person, color: Colors.white),
      //     snackPosition: SnackPosition.TOP,
      //   );
      String driverId = await storage.read(key: 'driverId') ?? '';

      driverRef.child('/${driverId}/tripRequest/requestDetail').update({
        "status": "completed",
      }).then((_) {
        // Data saved successfully!
        print("update success");
      }).catchError((error) {
        // The write failed...
        print("update error");
      });
      _isLoading.value = false;
      _tripStatus.value = 'stoped';
      service.invoke("stop-timer1");
      showDiaalog(price, distance, time);
    } else {
      _isLoading.value = false;
      // _isTripStarted.value = false;
      print('Trip could not be stoped on the server');
    }
  }
}

void showTripRport(
    BuildContext context, num? price, num? distance, String? time) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: ExactAssetImage(
              'assets/images/logo_bg_white.jpg', // Replace with your image path
            ),
          ),
          Text('Vip trip Report'),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: 170.0,
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Price",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                Text("${price} Birr",
                    style: TextStyle(color: Colors.green, fontSize: 18))
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Distance",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                Text("${distance} Km",
                    style: TextStyle(color: Colors.black, fontSize: 18))
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Waiting",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                Text("${time}",
                    style: TextStyle(color: Colors.black, fontSize: 18))
              ],
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Text(
              "Thank you for choosing VIP Taxi!",
              style: TextStyle(fontSize: 13, color: Colors.blue),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'OK',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}

void showDiaalog(num? price, num? distance, String? time) {
  Get.defaultDialog(
    title: "Trip Report",
    content: SingleChildScrollView(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Price",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            Text("${price} Birr",
                style: TextStyle(color: Colors.green, fontSize: 21))
          ],
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Distance",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            Text("${double.parse(distance!.toStringAsFixed(1))} Km",
                style: TextStyle(color: Colors.black, fontSize: 18))
          ],
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Waiting",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            Text("${time}", style: TextStyle(color: Colors.black, fontSize: 18))
          ],
        ),
        Divider(),
        SizedBox(
          height: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: ExactAssetImage(
                'assets/images/logo_bg_white.jpg', // Replace with your image path
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Thank you for choosing VIP Taxi!',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        )
      ]),
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              // Perform action when the dialog button is pressed
              Get.back();
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      )
    ],
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
