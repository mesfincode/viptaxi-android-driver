import 'package:driver/constants.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:driver/main.dart';
import 'package:driver/screens/new_request_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class NewTripRequestController extends GetxController {
  DatabaseReference driverRef = FirebaseDatabase.instance.ref('drivers');
  DatabaseReference requestRef = FirebaseDatabase.instance.ref('tripReqests');

  RequestController requestController = Get.find();
  @override
  void onInit() async {
    setUpListenNewRequest();
    super.onInit();
  }

  void setUpListenNewRequest() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    driverRef
        .child('/${driverId}/newRequest')
        .onValue
        .listen((DatabaseEvent event) {
      dynamic data = event.snapshot.value;
      print("newRequest");
      print(data);
      if (data != null) {
        // dynamic status = data['status'];
        getTripDetail(data['requestId']);
        //  Get.to(NewRequestScreen());
      }
    });
  }

  void getTripDetail(String tripId) async {
    dynamic event = await requestRef.child('/$tripId').once(DatabaseEventType.value);
    if (event.snapshot.exists) {
      // print(event.snapshot.value);
      dynamic data = event.snapshot.value;
      print(data);
      String status = data['status'] ;
      print(data['status']);
      if(status =="pending" || status == ARRIVING || status == ARRIVED || status == STARTED ){
        // getTripDetail(tripId);
          Future.delayed(Duration(seconds: 2), () {
         Get.to(NewRequestScreen( tripDetail: data,),transition: Transition.rightToLeft);
      });


      }
    } else {
      print('No data available.');
    }
    // requestController.getTripDetail(tripId);
  }
}
