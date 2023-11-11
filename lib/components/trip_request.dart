import 'package:flutter/material.dart';

class TripRequest extends StatefulWidget {
  const TripRequest({super.key});

  @override
  State<TripRequest> createState() => _TripRequestState();
}

class _TripRequestState extends State<TripRequest> {
  @override
  Widget build(BuildContext context) {
    return 
Align(
  alignment: Alignment.bottomCenter,
  child: Card(
    // margin: EdgeInsets.all(16.0),
    // elevation: 8.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    child: Container(
      height: MediaQuery.of(context).size.height * 0.25,
      color: Colors.blue,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rider Name: John Doe',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Rider Phone: +1234567890',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Pickup Address: 123 Main Street, Anytown, USA',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Destination Address: 456 Elm Street, Anytown, USA',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Accept trip request
                      print('Trip request accepted');
                    },
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Reject trip request
                      print('Trip request rejected');
                    },
                    child: Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  
  }
}