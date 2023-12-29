import 'dart:ffi';
import 'dart:math';

import 'package:driver/components/blinking_text.dart';
import 'package:driver/constants.dart';
import 'package:driver/controllers/profile_controller.dart';
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
  final _formKey = GlobalKey<FormState>();
  TextEditingController _riderNameController = TextEditingController();
  TextEditingController _riderPhoneController = TextEditingController();
  TextEditingController _pickupAddressController = TextEditingController();
  TextEditingController _destinationAddressController = TextEditingController();
  TextEditingController _pickupTimeController = TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.ref('drivers');
  DatabaseReference driverRef = FirebaseDatabase.instance.ref('drivers');
  final storage = new FlutterSecureStorage();
  ProfileController profileController = Get.find();

  RequestController requestController = Get.find();
  String tripReqestsId = '';
  TripRequestDetail? tripRequestDetail;
  TripController tripController = Get.find();

  bool _creatingNewOrder = false;
  @override
  void initState() {
    // TODO: implement initState
    getNewRequest();
    _pickupTimeController.text = "Now";

    _riderPhoneController.text = "09";
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
           
            tripRequestDetail = TripRequestDetail(
                riderName: requestDetail['riderName'],
                riderPhone: requestDetail['riderPhone'],
                riderPickUpAddress: requestDetail['pickUpAddress'],
                riderDestinatinoAddress: requestDetail['destination'],
                pickUpTime: requestDetail['pickUpTime'],
                status: requestDetail['status'],
                dateSent: formattedDate,
                sentBy: requestDetail['sentBy']
                );
            print("data null ------------");
          });
        } else {
          print("data null ------------");
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

  void createRequest() async {
    setState(() {
      _creatingNewOrder = true;
    });
    String driverId = await storage.read(key: 'driverId') ?? '';
    try {
      await driverRef.child('/${driverId}/tripRequest/requestDetail').update({
        "tripReqestsId": '1111111',
        "driverId": driverId,
        "driverName": "${profileController.firstName}",
        "riderName": _riderNameController.text,
        "riderPhone": _riderPhoneController.text,
        "pickUpAddress": _pickupAddressController.text,
        "destination": _destinationAddressController.text,
        "pickUpTime": _pickupTimeController.text,
        "sentBy": "${profileController.firstName}",
        "dateSent": DateTime.now().millisecondsSinceEpoch
      });
      await driverRef.child('/${driverId}/tripRequest/requestDetail').update({
        "status": "pending",
      });
      setState(() {
        _creatingNewOrder = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _creatingNewOrder = false;
      });
    }

    // driverRef.child('/${driverId}/tripRequest/requestDetail').update({
    //   "tripReqestsId": '1111111',
    //   "driverId": driverId,
    //   "driverName": "${profileController.firstName}",
    //   "riderName": _riderNameController.text,
    //   "riderPhone": _riderPhoneController.text,
    //   "riderPickUpAddress": _pickupAddressController.text,
    //   "riderDestinatinoAddress": _destinationAddressController.text,
    //   "pickUpTime": _pickupTimeController.text,
    //   "sentBy":"${profileController.firstName}",
    //   "dateSent": DateTime.now().millisecondsSinceEpoch
    // }).then((_) {

    //   driverRef.child('/${driverId}/tripRequest/requestStatus').update({
    //     "status": "pending",
    //   }).then((_) {
    //     // Data saved successfully!
    //      setState(() {
    //   _creatingNewOrder = false;
    // });
    //     print("update success");
    //   }).catchError((error) {
    //           _creatingNewOrder = false;

    //     // The write failed...
    //     print("update error");
    //   });
    //   print("update success");
    // }).catchError((error) {
    //         _creatingNewOrder = false;

    //   // The write failed...
    //   print("update error $error");
    // });
  }

  void acceptRequest() async {
    String driverId = await storage.read(key: 'driverId') ?? '';

    // tripRequestDetail?.driverId = driverId;
    //  tripController.updateTripStatusOnServer(tripRequestDetail!,ACCEPTED).then((value) => {
    //   if(value){
    //     print(ACCEPTED)
    //   }
    //  });

  }

  void declineTripRequest() async {
    String driverId = await storage.read(key: 'driverId') ?? '';
  
    // tripRequestDetail?.driverId = driverId;
    //  tripController.updateTripStatusOnServer(tripRequestDetail!,DECLINED).then((value) => {
    //   if(value){
    //     print("accepted")
    //   }
    //  });
    // driverRef.child('/${driverId}/tripRequest/requestDetail').update({
    //   "status": "declined",
    // }).then((_) {
    //   // Data saved successfully!
    //   print("update success");
    // }).catchError((error) {
    //   // The write failed...
    //   print("update error");
    // });
  }

  void cancelTrepRequest() async {
 String driverId = await storage.read(key: 'driverId') ?? '';
  
    // tripRequestDetail?.driverId = driverId;
    //  tripController.updateTripStatusOnServer(tripRequestDetail!,CANCELED).then((value) => {
    //   if(value){
    //     print(CANCELED)
    //   }
    //  });
    // driverRef.child('/${driverId}/tripRequest/requestDetail').update({
    //   "status": "canceled",
    // }).then((_) {
    //   // Data saved successfully!
    //   print("update success");
    // }).catchError((error) {
    //   // The write failed...
    //   print("update error");
    // });
  }

  void startTrip() async {
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
    try {
      await launchUrl(launchUri);
    } catch (e) {
      print("launch call err $e");
    }
    // await launchUrl(launchUri);
  }

  void _openDialog() {
    _riderNameController.clear();
    _pickupAddressController.clear();
    _destinationAddressController.clear();
    _pickupTimeController.text = "Now";

    _riderPhoneController.text = "09";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ride Details'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _riderNameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the rider name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Rider Name',
                    ),
                  ),
                  TextFormField(
                    controller: _riderPhoneController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the rider phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Rider Phone',
                    ),
                  ),
                  TextFormField(
                    controller: _pickupAddressController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the pickup address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Pickup Address',
                    ),
                  ),
                  TextFormField(
                    controller: _destinationAddressController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the destination address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Destination Address',
                    ),
                  ),
                  TextFormField(
                    controller: _pickupTimeController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the pickup time';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Pickup Time',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                OutlinedButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, do something with the data
                      String riderName = _riderNameController.text;
                      String riderPhone = _riderPhoneController.text;
                      String pickupAddress = _pickupAddressController.text;
                      String destinationAddress =
                          _destinationAddressController.text;
                      String pickupTime = _pickupTimeController.text;
                      createRequest();
                      Navigator.of(context).pop();
                      // Close the dialog

                      // Perform any further actions with the captured data
                      // ...
                    }
                  },
                ),
              ],
            )
          ],
        );
      },
    );
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/images/default_profile.jpeg'),
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
                                  _makePhoneCall(
                                      "0943766122"); // Replace with the desired phone number
                                },
                                icon: Icon(Icons.call),
                              ),
                            ],
                          )
                        ],
                      ),
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
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.near_me,
                                        color: Colors.red,
                                      ),
                                      // Text("Pickup"),
                                    ],
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${tripRequestDetail?.riderPickUpAddress}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              // padding: EdgeInsets.all(3),
                              // margin: EdgeInsets.only(bottom: 5),
                              // color: Color.fromARGB(255, 245, 242, 242),
                              child: Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.place,
                                        color: Colors.green,
                                      ),
                                      // Text("Destination"),
                                    ],
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${tripRequestDetail?.riderDestinatinoAddress}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
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
                        if (tripRequestDetail?.status == "declined")
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
                              try {
                                showYesOrNoDialog(context,
                                        "Are you sure you want to decline the trip ?")
                                    .then((value) => {
                                          if (value != null)
                                            {
                                              if (value) {declineTripRequest()}
                                            }
                                        });
                              } catch (e) {}
                            },
                            child: Text('Decline'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              acceptRequest();
                            },
                            child: Text(
                              'Accept',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),

                    if (tripRequestDetail?.status == "accepted")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              try {
                                showYesOrNoDialog(context,
                                        "Are you sure you want to cancel the trip ?")
                                    .then((value) => {
                                          if (value != null)
                                            {
                                              if (value) {cancelTrepRequest()}
                                            }
                                        });
                              } catch (e) {}
                            },
                            child: Text('Cancle Trip'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isStartTripButtonDisabled = true;
                              });
                              try {
                                showYesOrNoDialog(context, "Confirm Start Trip")
                                    .then((value) => {
                                          if (value != null)
                                            {
                                              if (value)
                                                {
                                                  tripController
                                                      .startTrip(
                                                          tripRequestDetail!)
                                                      .then((value) => {
                                                            setState(() {
                                                              _isStartTripButtonDisabled =
                                                                  true;
                                                            })
                                                          })
                                                }
                                            }
                                        });
                              } catch (e) {}
                            },
                            child: Text(
                              'Start Trip',
                              style: TextStyle(color: Colors.blue),
                            ),
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
                        tripRequestDetail?.status == "declined" ||
                        tripRequestDetail?.status == "canceled")
                      Container(
                        width: double.infinity,
                        // height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text(
                            //   'Waiting for new order from call center',
                            //   style:
                            //       TextStyle(fontSize: 16, color: Colors.blue),
                            // ),
                            Container(
                              width: double.infinity,
                              child: _creatingNewOrder
                                  ? Center(child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      onPressed: () {
                                        // Get.to(CarsScreen());

                                        _openDialog();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 244, 90, 82),
                                        padding: EdgeInsets.all(
                                            12), // Adjust the padding as needed
                                        shadowColor:
                                            Color.fromARGB(255, 222, 217, 217),
                                        elevation: 20,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Adjust the border radius as needed
                                        ),
                                        // side: BorderSide(
                                        //   color: Color.fromARGB(255, 254, 17, 0), // Set the color of the button outline
                                        //   width: 2.0, // Set the width of the button outline
                                        // ),
                                      ),
                                      child: Text(
                                        "Create New Order",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                            )
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
                          "Loading Trip Detail",
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
