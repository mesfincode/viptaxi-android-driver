import 'package:driver/controllers/request_controller.dart';
import 'package:driver/controllers/trip_controller.dart';
import 'package:driver/models/TripRequestDetail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
    try{
driverRef
        .child('/${driverId}/tripRequest')
        .onValue
        .listen((DatabaseEvent event) {
      dynamic data = event.snapshot.value;
     if(data !=null){
       dynamic requestDetail = data['requestDetail'];
      dynamic tripRequestStatus = data['requestStatus'];

// DateTime pickuptime = DateTime.fromMillisecondsSinceEpoch(data['pickUpTime']);
// DateTime date = timestamp.toDate();
 final date = DateTime.fromMillisecondsSinceEpoch(requestDetail['dateSent']);
  
  final formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(date);
      setState(() {
        if(tripRequestStatus !=null){
 tripRequestDetail = TripRequestDetail(
            riderName: requestDetail['riderName'],
            riderPhone: requestDetail['riderPhone'],
            riderPickUpAddress: requestDetail['pickUpAddress'],
            riderDestinatinoAddress: requestDetail['destination'],
            pickUpTime: requestDetail['pickUpTime'],
            status: tripRequestStatus['status'],
            dateSent:  formattedDate


            );
        }else{
           tripRequestDetail = TripRequestDetail(
            riderName: requestDetail['riderName'],
            riderPhone: requestDetail['riderPhone'],
            riderPickUpAddress: requestDetail['pickUpAddress'],
            riderDestinatinoAddress: requestDetail['destination'],
            pickUpTime: requestDetail['pickUpTime'],
            status: "",
            dateSent:  formattedDate


            );
        }
       
           
      });
     }

      // print(data);
      // updateStarCount(data);
    });
    }catch(e){
      print(e);
    }
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


  Future<dynamic> showYesOrNoDialog(BuildContext context,String content) {
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
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw Exception('Could not launch $launchUri');
    }
    // await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    bool _isStartTripButtonDisabled = false;
  
    return Container(
      height: 280,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // BottomConnectionIndicator(),
            if (tripRequestDetail != null)
              Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/default_profile.jpeg'),
                          radius: 25,
                        ),
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            
                            Text('${tripRequestDetail?.riderName}'),
                            Text(
                                '${tripRequestDetail?.riderPhone}'),
                          ],
                        ),
                         IconButton(
                                  
                                  onPressed: () {
                                    _makePhoneCall(tripRequestDetail!
                                        .riderPhone!); // Replace with the desired phone number
                                  },
                                  icon: Icon(Icons.call),
                                ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text('Pickup: ${tripRequestDetail?.riderPickUpAddress}'),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                          'Destination:  ${tripRequestDetail?.riderDestinatinoAddress}'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('PickupTime:  ${tripRequestDetail?.pickUpTime}'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Status:  ${tripRequestDetail?.status}'),
                    ],
                  ),
                    Row(
                    children: [
                      Text('Date:  ${tripRequestDetail?.dateSent}'),
                    ],
                  ),
                   Row(
                    children: [
                      Text('Sent By:  Admin1'),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (tripRequestDetail?.status == "pending")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      
                        ElevatedButton(
                          onPressed: () {
                              showYesOrNoDialog(context, "Are you sure you want to reject the trip ?").then((value) => {
                              if(value){
                            rejectTripRequest()

                              }
                            });
                          },
                          child: Text('Reject'),
                        ),
                          ElevatedButton(
                          onPressed: () {
                            acceptRequest();
                          },
                          child: Text('Accept'),
                        ),
                      ],
                    ),
                  if (tripRequestDetail?.status == "accepted")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                         ElevatedButton(
                          onPressed: () {
                            showYesOrNoDialog(context, "Are you sure you want to cancel the trip ?").then((value) => {
                              if(value){
                            cancelTrepRequest()

                              }
                            });
                          },
                          child: Text('Cancle Trip'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isStartTripButtonDisabled = true;
                            });
                            showYesOrNoDialog(context,"Confirm Start Trip").then((value) => {
                                  if (value)
                                    {
                                      tripController
                                          .startTrip(tripRequestDetail!)
                                          .then((value) => {
                                                setState(() {
                                                  _isStartTripButtonDisabled =
                                                      true;
                                                })
                                              })
                                    }
                                });
                          },
                          child: Text('Start Trip'),
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
                          ElevatedButton(
                            onPressed: () {
                              // acceptRequest();
                              // stopTrip();
                            },
                            child: Text('Trip on going'),
                          ),
                          // ElevatedButton(
                          //   onPressed: () {},
                          //   child: Text('Cancle Trip'),
                          // ),
                        ],
                      ),
                    ),
                  if (tripRequestDetail?.status == "completed")
                    Container(
                      width: double.infinity,
                      // height: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // acceptRequest();
                              // stopTrip();
                            },
                            child: Text('Waiting for new order from call center'),
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
              Center(
                child: Column(children: [
                  LinearProgressIndicator(color: Colors.red,),
                  Text("Waiting for Trip request from call center")
                ]),
              )
          ],
        ),
      ),
    );
  }
}
