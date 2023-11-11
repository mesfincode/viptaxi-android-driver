import 'package:driver/controllers/request_controller.dart';
import 'package:driver/controllers/trip_controller.dart';
import 'package:driver/models/TripRequestDetail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomSheetComponent extends StatefulWidget {
  const BottomSheetComponent({super.key});

  @override
  State<BottomSheetComponent> createState() => _BottomSheetComponentState();
}

class _BottomSheetComponentState extends State<BottomSheetComponent> {
  DatabaseReference ref = FirebaseDatabase.instance.ref('drivers');
  DatabaseReference driverRef = FirebaseDatabase.instance.ref('drivers');
  final storage = new FlutterSecureStorage();

  RequestController requestController = Get.find();
  String tripReqestsId = '';
  TripRequestDetail? tripRequestDetail;
  TripController tripController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    getNewRequest();
    super.initState();
  }

  void getNewRequest() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        String driverId = await storage.read(key: 'driverId') ?? '';

    // tripReqestsId = sharedPreferences.getString('driverId') ?? '';
    driverRef
        .child('/${driverId}/tripRequest')
        .onValue
        .listen((DatabaseEvent event) {
      dynamic data = event.snapshot.value;
      dynamic requestDetail = data['requestDetail'];
      dynamic tripRequestStatus = data['requestStatus'];

// DateTime pickuptime = DateTime.fromMillisecondsSinceEpoch(data['pickUpTime']);
// DateTime date = timestamp.toDate();
      setState(() {
        tripRequestDetail = TripRequestDetail(
            riderName: requestDetail['riderName'],
            riderPhone: requestDetail['riderPhone'],
            riderPickUpAddress: requestDetail['pickUpAddress'],
            riderDestinatinoAddress: requestDetail['destination'],
            pickUpTime: requestDetail['pickUpTime'],
            status: tripRequestStatus['status']);
      });

      // print(data);
      // updateStarCount(data);
    });
    // dynamic data = await requestController.fetchNewTripRequest(tripReqestsId);
    // print("data ${data['riderName']}");
    // setState(() {
    //   tripRequestDetail = TripRequestDetail(
    //       riderName: data['riderName'],
    //       riderPhone: data['riderPhone'],
    //       riderPickUpAddress: data['riderPickUpAddress'],
    //       riderDestinatinoAddress: data['riderDestinatinoAddress'],
    //       pickUpTime: data['pickUpTime'],
    //       status: data['status']);
    // });
  }

  void acceptRequest() async {
            String driverId = await storage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/tripRequest/requestStatus').update({
      "status": "accepted",
    }).then((_) {
      // Data saved successfully!
      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // BottomConnectionIndicator(),
            if(tripRequestDetail != null)
             Column(
              children: [
                 CircleAvatar(
              backgroundImage: AssetImage('assets/images/default_profile.jpeg'),
              radius: 25,
            ),
            Text('Rider Name: ${tripRequestDetail?.riderName}'),
            Text('Rider Phone: ${tripRequestDetail?.riderPhone}'),
            Text('Pickup: ${tripRequestDetail?.riderPickUpAddress}'),
            Text('Destination:  ${tripRequestDetail?.riderDestinatinoAddress}'),
            Text('pickupTime:  ${tripRequestDetail?.pickUpTime}'),
            Text('stauts:  ${tripRequestDetail?.status}'),

            SizedBox(height: 16),
            if (tripRequestDetail?.status == "pending")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      acceptRequest();
                    },
                    child: Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Reject'),
                  ),
                ],
              ),
            if (tripRequestDetail?.status == "accepted")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // acceptRequest();
                      tripController.startTrip();
                    },
                    child: Text('Start Trip'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Cancle Trip'),
                  ),
                ],
              ),
              ],
             ),

             if(tripRequestDetail == null)
             Center(child: Column(children: [
              CircularProgressIndicator(),
              Text("Fetching new request")
             ]),)
          ],
        ),
      ),
    );
  }
}
