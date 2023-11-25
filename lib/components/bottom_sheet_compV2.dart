import 'dart:ffi';

import 'package:driver/components/blinking_text.dart';
import 'package:driver/controllers/trip_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/request_controller.dart';
import '../models/TripRequestDetail.dart';

class BottomSheetComponentV2 extends StatefulWidget {
  const BottomSheetComponentV2({super.key});

  @override
  State<BottomSheetComponentV2> createState() => _BottomSheetComponentV2State();
}

class _BottomSheetComponentV2State extends State<BottomSheetComponentV2> {
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
    try {
      driverRef
          .child('/${driverId}/tripRequest')
          .onValue
          .listen((DatabaseEvent event) {
        dynamic data = event.snapshot.value;
        if (data != null) {
          dynamic requestDetail = data['requestDetail'];
          dynamic tripRequestStatus = data['requestStatus'];

// DateTime pickuptime = DateTime.fromMillisecondsSinceEpoch(data['pickUpTime']);
// DateTime date = timestamp.toDate();
          final date =
              DateTime.fromMillisecondsSinceEpoch(requestDetail['dateSent']);

          final formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(date);
          setState(() {
            if (tripRequestStatus != null) {
              tripRequestDetail = TripRequestDetail(
                  riderName: requestDetail['riderName'],
                  riderPhone: requestDetail['riderPhone'],
                  riderPickUpAddress: requestDetail['pickUpAddress'],
                  riderDestinatinoAddress: requestDetail['destination'],
                  pickUpTime: requestDetail['pickUpTime'],
                  status: tripRequestStatus['status'],
                  dateSent: formattedDate);
            } else {
              tripRequestDetail = TripRequestDetail(
                  riderName: requestDetail['riderName'],
                  riderPhone: requestDetail['riderPhone'],
                  riderPickUpAddress: requestDetail['pickUpAddress'],
                  riderDestinatinoAddress: requestDetail['destination'],
                  pickUpTime: requestDetail['pickUpTime'],
                  status: "",
                  dateSent: formattedDate);
            }
          });
        }

        // print(data);
        // updateStarCount(data);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  
    super.dispose();
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

  void rejectTripRequest() async {
    String driverId = await storage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/tripRequest/requestStatus').update({
      "status": "rejected",
    }).then((_) {
      // Data saved successfully!
      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  void cancelTrepRequest() async {
    String driverId = await storage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/tripRequest/requestStatus').update({
      "status": "canceled",
    }).then((_) {
      // Data saved successfully!
      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  void startTrip() async {
    String driverId = await storage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/tripRequest/requestStatus').update({
      "status": "started",
    }).then((_) {
      // Data saved successfully!

      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  Future<dynamic> showYesOrNoDialog(BuildContext context, String content) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('VIP Taxi '),
          content: Text(
            content,
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try{
      await launchUrl(launchUri);

    }catch(e){
      print("launch call err $e");
    }
    // await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    bool _isStartTripButtonDisabled = false;

    return Container(
      height: 300,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              if (tripRequestDetail != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 3),
                        width: 50, // Set the desired width of the line
                        child: Divider(
                          height: 10, // Adjust the height/thickness of the line
                          thickness: 5, // Set the thickness of the line
                          color: Color.fromARGB(
                              255, 241, 238, 238), // Set the color of the line
                        ),
                      ),
                    ),

                    // Image.asset('assets/images/car11.png'),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/default_profile.jpeg'),
                          radius: 25,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tripRequestDetail?.riderName}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${tripRequestDetail?.riderPhone}',
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            IconButton(
                              iconSize: 30,
                              color: Colors.blue,
                              onPressed: () {
                                _makePhoneCall("0943766122"); // Replace with the desired phone number
                              },
                              icon: Icon(Icons.call),
                            ),
                          ],
                        )
                      ],
                    ),
                    // Divider(),
                    SizedBox(
                      height: 3,
                    ),
                    GestureDetector(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // padding: EdgeInsets.all(3),
                              // margin: EdgeInsets.only(bottom: 5),
                              // color: Color.fromARGB(255, 245, 242, 242),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.near_me,
                                        color: Colors.red,
                                      ),
                                      Text("Pickup"),
                                    ],
                                  ),
                                  Text(
                                      '${tripRequestDetail?.riderPickUpAddress}'),
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              // padding: EdgeInsets.all(3),
                              // margin: EdgeInsets.only(bottom: 5),
                              // color: Color.fromARGB(255, 245, 242, 242),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.place,
                                        color: Colors.green,
                                      ),
                                      Text("Destination"),
                                    ],
                                  ),
                                  Text(
                                      '${tripRequestDetail?.riderDestinatinoAddress}'),
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              // padding: EdgeInsets.all(3),
                              // margin: EdgeInsets.only(bottom: 5),
                              // color: Color.fromARGB(255, 245, 242, 242),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.blue,
                                      ),
                                      Text("Time of pickup"),
                                    ],
                                  ),
                                  Text('${tripRequestDetail?.pickUpTime}'),
                                ],
                              ),
                            ),
                          ]),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (tripRequestDetail?.status == "pending")
                          BlinkingText(
                            text: '${tripRequestDetail?.status}',
                          ),
                        if (tripRequestDetail?.status == "accepted")
                          BlinkingText(
                            text: '${tripRequestDetail?.status}',
                          ),
                        if (tripRequestDetail?.status == "started")
                          BlinkingText(
                            text: '${tripRequestDetail?.status}',
                          ),
                        if (tripRequestDetail?.status == "completed")
                          Text(
                            '${tripRequestDetail?.status}',
                            style: TextStyle(fontSize: 23, color: Colors.green),
                          ),
                        if (tripRequestDetail?.status == "canceled")
                          Text(
                            '${tripRequestDetail?.status}',
                            style: TextStyle(fontSize: 23, color: Colors.red),
                          ),
                        if (tripRequestDetail?.status == "rejected")
                          Text(
                            '${tripRequestDetail?.status}',
                            style: TextStyle(fontSize: 23, color: Colors.red),
                          ),
                      ],
                    ),

                    if (tripRequestDetail?.status == "pending")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              acceptRequest();
                           
                            },
                            child: Text(
                              'Accept',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showYesOrNoDialog(context,
                                      "Are you sure you want to reject the trip ?")
                                  .then((value) => {
                                        if (value) {rejectTripRequest()}
                                      });
                            },
                            child: Text('Reject'),
                          ),
                        ],
                      ),

                    if (tripRequestDetail?.status == "accepted")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isStartTripButtonDisabled = true;
                              });
                              showYesOrNoDialog(context, "Confirm Start Trip")
                                  .then((value) => {
                                        if (value)
                                          {
                                            tripController
                                                .startTrip(
                                                    tripRequestDetail!
                                                        .riderName,
                                                    tripRequestDetail!
                                                        .riderPhone)
                                                .then((value) => {
                                                      setState(() {
                                                        _isStartTripButtonDisabled =
                                                            true;
                                                      })
                                                    })
                                          }
                                      });
                            },
                            child: Text(
                              'Start Trip',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showYesOrNoDialog(context,
                                      "Are you sure you want to cancel the trip ?")
                                  .then((value) => {
                                        if (value) {cancelTrepRequest()}
                                      });
                            },
                            child: Text('Cancle Trip'),
                          ),
                        ],
                      ),
                    if (tripRequestDetail?.status == "started")
                      Container(
                        width: double.infinity,
                        // height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Trip has been started !")
                            // ElevatedButton(
                            //   onPressed: () {},
                            //   child: Text('Cancle Trip'),
                            // ),
                          ],
                        ),
                      ),

                    if (tripRequestDetail?.status == "completed" ||
                        tripRequestDetail?.status == "rejected" ||
                        tripRequestDetail?.status == "canceled")
                      Container(
                        width: double.infinity,
                        // height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Waiting for new order from call center',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                            // ElevatedButton(
                            //   onPressed: () {},
                            //   child: Text('Cancle Trip'),
                            // ),
                          ],
                        ),
                      ),
                  ],
                ),
              if (tripRequestDetail == null)
                Container(
                  // height: double.infinity,

                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 3),
                          width: 50, // Set the desired width of the line
                          child: Divider(
                            height:
                                10, // Adjust the height/thickness of the line
                            thickness: 5, // Set the thickness of the line
                            color: Color.fromARGB(255, 241, 238,
                                238), // Set the color of the line
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Waiting for Trip request from call center",
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        LinearProgressIndicator(
                          color: Colors.red,
                        ),
                      ]),
                )
            ],
          )),
    );
  }
}
