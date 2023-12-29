import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CreateOnStreetTrip extends StatefulWidget {
  const CreateOnStreetTrip({super.key});

  @override
  State<CreateOnStreetTrip> createState() => _CreateOnStreetTripState();
}

class _CreateOnStreetTripState extends State<CreateOnStreetTrip> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.only(left: 30,right: 30),
        // width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Get.to(CarsScreen());
    
            // _openDialog();
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 244, 90, 82),
            padding: EdgeInsets.all(12), // Adjust the padding as needed
            shadowColor: Color.fromARGB(255, 222, 217, 217),
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8), // Adjust the border radius as needed
            ),
            // side: BorderSide(
            //   color: Color.fromARGB(255, 254, 17, 0), // Set the color of the button outline
            //   width: 2.0, // Set the width of the button outline
            // ),
          ),
          child: Text(
            "Create On Street Trip",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
