import 'package:driver/components/blinking_text.dart';
import 'package:driver/constants.dart';
import 'package:driver/controllers/trip_controller.dart';
import 'package:driver/main.dart';
import 'package:driver/models/TripRequestDetail.dart';
import 'package:driver/screens/home_screen2.dart';
import 'package:driver/screens/home_screen3.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'package:sliding_up_panel/sliding_up_panel.dart';

final PanelController panelController = PanelController();

class NewRequestScreen extends StatefulWidget {
  final dynamic tripDetail;
  const NewRequestScreen({super.key, this.tripDetail});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  DatabaseReference tripRif = FirebaseDatabase.instance.ref('tripReqests');
  TripController tripController = Get.find();
  late GoogleMapController mapController;
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor driverIcon;
  TripRequestDetail? tripRequestDetail;

  LatLng? sourceLatLng;
  LatLng? destLatLng;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String tripRequestStatus = "pending";
  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        width: 3,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapAPIKey,
      PointLatLng(
          widget.tripDetail['sourceLat'], widget.tripDetail['sourceLng']),
      PointLatLng(widget.tripDetail['destLat'], widget.tripDetail['destLng']),
      travelMode: TravelMode.driving,
      // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    );
    if (result.distance != null && result.duration != null) {
      print('Distance: ${result.distance}');
      print('Duration: ${result.duration}');
      final distanceString = result.distance!;
      final distanceInKilometer = double.parse(distanceString.substring(
          0,
          distanceString.length -
              2)); // Extract substring and convert to double
      print('Distance: $distanceInKilometer km');

      // tripRequestController.tripRequest.distanceEstimation =
      //     distanceInKilometer;
      // tripRequestController.tripRequest.durationMunitEstimqtion =
      //     result.duration;
      // tripRequestController.tripRequest.priceEstimation =
      //     distanceInKilometer * 60 + 150;
      // return result; // Use returned PolylineResult for drawing the route
    } else {
      print('Distance and duration not available in this response.');
    }
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _addPolyLine();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void setInitialCameraPosition(LatLng source, LatLng destination) {
    double centerLat = (source.latitude + destination.latitude) / 2;
    double centerLng = (source.longitude + destination.longitude) / 2;

    CameraPosition initialPosition = CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: 12.3, // Adjust the initial zoom level as needed
    );

    mapController.moveCamera(CameraUpdate.newCameraPosition(initialPosition));
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  @override
  void initState() {
    // TODO: implement initState
    sourceLatLng =
        LatLng(widget.tripDetail['sourceLat'], widget.tripDetail['sourceLng']);
    destLatLng =
        LatLng(widget.tripDetail['destLat'], widget.tripDetail['destLng']);
    _addMarker(sourceLatLng!, "origin", BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(
        destLatLng!, "destination", BitmapDescriptor.defaultMarkerWithHue(90));

    _getPolyline();
    getNewRequest();
       WidgetsBinding.instance.addPostFrameCallback((_) {
      // This code will be executed after the widget is built
      panelController.open();
    });
    super.initState();
  }

  void getNewRequest() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    // tripReqestsId = sharedPreferences.getString('driverId') ?? '';
    try {
      tripRif
          .child('/${widget.tripDetail['tripReqestsId']}')
          .onValue
          .listen((DatabaseEvent event) {
        dynamic requestDetail = event.snapshot.value;
        if (requestDetail != null) {
          print("trip Status ${requestDetail}");
          setState(() {
            tripRequestStatus = requestDetail['status'];
          });
            //  dynamic requestDetail = data['requestDetail'];
          // dynamic tripRequestStatus = data['requestStatus'];

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

  void centerMapBetweenPoints(LatLng source, LatLng destination) {
    double minLat = math.min(source.latitude, destination.latitude);
    double maxLat = math.max(source.latitude, destination.latitude);
    double minLng = math.min(source.longitude, destination.longitude);
    double maxLng = math.max(source.longitude, destination.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void acceptRequest() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    // tripRequestDetail?.driverId = driverId;
    tripController
        .updateTripStatusOnServer(widget.tripDetail['tripReqestsId'], ACCEPTED)
        .then((value) => {
              if (value) {print(ACCEPTED)}
            });
  }

  void makeArriving() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    // tripRequestDetail?.driverId = driverId;
    tripController
        .updateTripStatusOnServer(widget.tripDetail['tripReqestsId'], ARRIVING)
        .then((value) => {
              if (value) {print(ARRIVING)}
            });
  }

  void makeArrived() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    // tripRequestDetail?.driverId = driverId;
    tripController
        .updateTripStatusOnServer(widget.tripDetail['tripReqestsId'], ARRIVED)
        .then((value) => {
              if (value) {print(ARRIVED)}
            });
  }

  void declineTripRequest() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    // tripRequestDetail?.driverId = driverId;
    tripController
        .updateTripStatusOnServer(widget.tripDetail['tripReqestsId'], DECLINED)
        .then((value) => {
              if (value) {print("accepted")}
            });
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
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    // tripRequestDetail?.driverId = driverId;
    tripController
        .updateTripStatusOnServer(widget.tripDetail['tripReqestsId'], CANCELED)
        .then((value) => {
              if (value) {print(CANCELED)}
            });
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
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: Text("new trip "),),
        body: Stack(
      children: [
        Positioned(
          top: 0,
          bottom: MediaQuery.of(context).size.height * 0.3,
          left: 0,
          right: 0,
          child: GoogleMap(
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition:
                CameraPosition(target: destLatLng!, zoom: 14),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            tiltGesturesEnabled: true,
            compassEnabled: false,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;

              // centerMapBetweenPoints(sourcLatLang,destLatLang);
              setInitialCameraPosition(sourceLatLng!, destLatLng!);
            },
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
        ),
        // if(tripRequestStatus == STARTED)
        DashboardV2(),
        Positioned(
            top: 40,
            left: 20,
            // right: 20,
            child: Container(
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Get.offAll(HomeScreen3());
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      )),
                  // Text("${tripRequestController.tripRequest.destAdress}",overflow: TextOverflow.clip,),
                  // Flexible(
                  //   child: Text(
                  //     "To: ${tripRequestController.tripRequest.destAdress}",
                  //     overflow: TextOverflow
                  //         .ellipsis, // Optional: Truncate long text with ellipsis
                  //   ),
                  // )
                  // Text("Kaliti")
                ],
              ),
            )),
        SlidingUpPanel(
          padding: EdgeInsets.all(16),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
          // backdropColor: primaryColor,
          backdropTapClosesPanel: true,
          minHeight: MediaQuery.of(context).size.height * 0.35,
          maxHeight: MediaQuery.of(context).size.height * 0.55,
          onPanelOpened: () {
            // Do something when the panel is opened
            print("panel opened");
            setState(() {
              // slidingPanelOpen = true;
            });
          },
          // body: Text("this is body panel"),
          onPanelClosed: () {
            // Do something when the panel is closed
            print("panel closed");
            setState(() {
              // slidingPanelOpen = false;
            });
          },
          controller: panelController,

          panel: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 16),
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 208, 197, 196),
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              
              // if (!slidingPanelOpen)
              Column(
                children: [
                  // Text("Where do you like to go"),
                  // Image.asset('assets/images/car11.png'),

                  // SizedBox(height: 16),
                  // OutlinedButton(
                  //     onPressed: () {
                  //       panelController.open();
                  //     },
                  //     child: Text("Where to")),
                if(tripRequestStatus != "pending")
                  SingleChildScrollView(
                    // scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              '${widget.tripDetail['riderName']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${widget.tripDetail['riderPhone']}',
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
                                // _makePhoneCall(
                                //     "0943766122"); // Replace with the desired phone number
                              },
                              icon: Icon(Icons.call),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    // decoration: BoxDecoration(color: Colors.white),
                    child: Column(children: [
                      Row(
                        children: [
                          Icon(
                            Icons.near_me,
                            color: Colors.red,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              "${widget.tripDetail['pickUpAddress']}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            color: Colors.green,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              "${widget.tripDetail['destination']}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wallet,
                                size: 30,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                // "${tripRequestController.tripRequest.carModel}",
                                "${widget.tripDetail['distanceEstimation']} Km",
                                style: TextStyle(fontSize: 19),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (widget.tripDetail['priceEstimation'] != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(Icons.wallet_sharp),
                                Text(
                                  "${widget.tripDetail['priceEstimation']} ETB",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          if (widget.tripDetail['priceEstimation'] == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(Icons.wallet_sharp),
                                Text(
                                  "_ _ _ETB",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                        ],
                      ),

                      // OutlinedButton(
                      //     onPressed: () {
                      //       tripRequestController.createTrip();
                      //       print(tripRequestController.tripRequest
                      //           .toJson());
                      //     },
                      //     child: Text("Confirm ")),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tripRequestStatus == "pending")
                            BlinkingText(
                              text: '${tripRequestStatus}',
                            ),
                          if (tripRequestStatus == "accepted")
                            BlinkingText(
                              text: '${tripRequestStatus}',
                            ),
                          if (tripRequestStatus == ARRIVING)
                            BlinkingText(
                              text: '${tripRequestStatus}',
                            ),
                          if (tripRequestStatus == ARRIVED)
                            BlinkingText(
                              text: '${tripRequestStatus}',
                            ),
                          if (tripRequestStatus == "started")
                            BlinkingText(
                              text: '${tripRequestStatus}',
                            ),
                          if (tripRequestStatus == "completed")
                            Text(
                              '${tripRequestStatus}',
                              style:
                                  TextStyle(fontSize: 23, color: Colors.green),
                            ),
                          if (tripRequestStatus == "canceled")
                            Text(
                              '${tripRequestStatus}',
                              style: TextStyle(fontSize: 23, color: Colors.red),
                            ),
                          if (tripRequestStatus == "declined")
                            Text(
                              '${tripRequestStatus}',
                              style: TextStyle(fontSize: 23, color: Colors.red),
                            ),
                        ],
                      ),
                      if (tripRequestStatus == "pending")
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
                                                if (value)
                                                  {declineTripRequest()}
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

                      if (tripRequestStatus == "accepted")
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
                                makeArriving();
                                // setState(() {
                                //   _isStartTripButtonDisabled = true;
                                // });
                                // try {
                                //   showYesOrNoDialog(context, "Confirm Start Trip")
                                //       .then((value) => {
                                //             if (value != null)
                                //               {
                                //                 if (value)
                                //                   {
                                //                     // tripController
                                //                     //     .startTrip(
                                //                     //         tripRequestDetail!)
                                //                     //     .then((value) => {
                                //                     //           setState(() {
                                //                     //             _isStartTripButtonDisabled =
                                //                     //                 true;
                                //                     //           })
                                //                     //         })
                                //                   }
                                //               }
                                //           });
                                // } catch (e) {}
                              },
                              child: Text(
                                'Arriving',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      if (tripRequestStatus == ARRIVING)
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
                              onPressed: () {
                                makeArrived();
                              },
                              child: Text(
                                'Arrived',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      if (tripRequestStatus == ARRIVED)
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
                              onPressed: () {
                                try {
                                  showYesOrNoDialog(
                                          context, "Confirm Start Trip")
                                      .then((value) => {
                                            if (value != null)
                                              {
                                                if (value)
                                                  {
                                                    tripController
                                                        .startTrip(
                                                            tripRequestDetail!)
                                                        .then((value) => {
                                                              // setState(() {
                                                              //   _isStartTripButtonDisabled =
                                                              //       true;
                                                              // })
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
                      if (tripRequestStatus == "started")
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

                      if (tripRequestStatus == "completed" ||
                          tripRequestStatus == "declined" ||
                          tripRequestStatus == "canceled")
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
                              // Container(
                              //   width: double.infinity,
                              //   child: _creatingNewOrder
                              //       ? Center(child: CircularProgressIndicator())
                              //       : ElevatedButton(
                              //           onPressed: () {
                              //             // Get.to(CarsScreen());

                              //             // _openDialog();
                              //           },
                              //           style: OutlinedButton.styleFrom(
                              //             backgroundColor:
                              //                 Color.fromARGB(255, 244, 90, 82),
                              //             padding: EdgeInsets.all(
                              //                 12), // Adjust the padding as needed
                              //             shadowColor:
                              //                 Color.fromARGB(255, 222, 217, 217),
                              //             elevation: 20,
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(
                              //                   8), // Adjust the border radius as needed
                              //             ),
                              //             // side: BorderSide(
                              //             //   color: Color.fromARGB(255, 254, 17, 0), // Set the color of the button outline
                              //             //   width: 2.0, // Set the width of the button outline
                              //             // ),
                              //           ),
                              //           child: Text(
                              //             "Create New Order",
                              //             style: TextStyle(color: Colors.white),
                              //           ),
                              //         ),
                              // )
                            ],
                          ),
                        ),
                      // Obx((){
                      //   if(tripRequestController.isLoading){
                      //     return CircularProgressIndicator();
                      //   }else {
                      //     return  GestureDetector(
                      //       onTap: (){

                      //          tripRequestController.createTrip(tripRequestController.tripRequest).then((value) => {
                      //           launchScreen(context, RequestedTripScreen(),pageRouteAnimation:PageRouteAnimation.Slide)
                      //          });
                      //       print(tripRequestController.tripRequest
                      //           .toJson());
                      //           print("object");
                      //           print(tripRequestController.tripRequest.destLng);
                      //       },
                      //        child: Container(

                      //         alignment: Alignment.center,
                      //         width: MediaQuery.sizeOf(context).width *.8,
                      //         padding: EdgeInsets.only(
                      //             left: 12, right: 12, top: 7, bottom: 7),
                      //         decoration: BoxDecoration(
                      //           color: Colors.green,
                      //             border: Border.all(color: Colors.green),
                      //             borderRadius: BorderRadius.all(
                      //                 Radius.circular(5))),
                      //         child: Text("Confirm",style: TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.bold),))
                      //     );
                      //   }
                      // })
                    ]),
                  )
                  // Image.asset('assets/images/car11.png'),
                ],
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    ));
  }
}
