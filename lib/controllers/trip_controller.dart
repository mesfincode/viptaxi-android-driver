import 'package:driver/controllers/request_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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

  @override
  void onInit() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _tripStatus.value = await sharedPreferences.getString('tripStatus')??'';
    super.onInit();

  }

 void startTrip() async {
     print('trip controller');

    _isLoading.value = true;
    bool tripCreatedOnServer;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String latitude = sharedPreferences.getString('currentLatitude') ?? '--';
    String longitude = sharedPreferences.getString('currentLongitude') ?? '--';

    tripCreatedOnServer = await requestController.startTripRequest(
        {'latitude': latitude, 'longitude': longitude, 'geohash': 'aksjff'});
    if (tripCreatedOnServer) {
      print('trip created on the server continue');
      service.invoke("start-timer1");
      _isLoading.value = false;
      _tripStatus.value = "started";
         print('Trip created on the server');
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

stopTrip(num price,num distance, String time)async {
    _isLoading.value = true;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  
    String tripId = await sharedPreferences.getString('tripId') ?? '';
    String latitude = sharedPreferences.getString('currentLatitude') ?? '--';
    String longitude = sharedPreferences.getString('currentLongitude') ?? '--';
    RequestController requestController = Get.put(RequestController());
    bool tripStopedOnTheServer = await requestController.stopTripRequest(
        tripId,
        {
          'latitude': latitude,
          'longitude': longitude,
          'geohash': 'aksjff'
        },
        distance.toInt(),
        price.toInt(),
        time);
    if(tripStopedOnTheServer){
      print('Trip stoped on the server');
        //  Get.snackbar(
        //     "app",
        //     "Trip stoped on the server",
        //     icon: Icon(Icons.person, color: Colors.white),
        //     snackPosition: SnackPosition.TOP,
        //   );
           _isLoading.value = false;
      _tripStatus.value = 'stoped';
      service.invoke("stop-timer1");
      showDiaalog( price, distance, time);
    }else{
       _isLoading.value = false;
      // _isTripStarted.value = false;
      print('Trip could not be stoped on the server');
    }
  }
}
void showDiaalog( num? price, num? distance, String? time){
   Get.defaultDialog(
    title: "Vip taxi trip report",
    content:  SingleChildScrollView(
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