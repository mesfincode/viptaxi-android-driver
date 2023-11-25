import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:driver/constants/headers.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:driver/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    String phoneNumb = '';
    RequestController authController = Get.put(RequestController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Image.asset(
                'assets/images/logo_bg_white.jpg', // Replace with your image path
                height: 100,
                width: 100,
              ),
              Text(
                "Enter your phone to get started",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Text("you will receive a verification code"),
              SizedBox(
                height: 20,
              ),
              // InternationalPhoneNumberInput(
              //   initialValue: phoneNumber,
              //   onInputChanged: (PhoneNumber number) {
              //     setState(() {
              //       phoneNumber = number;
              //     });
              //   },
              //   selectorConfig: SelectorConfig(
              //     selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              //   ),
              //   // inputDecoration: InputDecoration(
              //   //   labelText: 'Phone number',
              //   //   contentPadding: EdgeInsets.symmetric(
              //   //       vertical: 10, horizontal: 12), // Set the padding
              //   //   border: OutlineInputBorder()
              //   // ),
              //   inputDecoration: InputDecoration(
              //     labelText: 'Enter Phone number',
              //     contentPadding:
              //         EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              //     border: UnderlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Colors.grey, // Set the color of the bottom border
              //         width: 1.0, // Set the width of the bottom border
              //       ),
              //     ),
              //     // Add other input decoration properties as needed
              //   ),
              //   onInputValidated: (bool value) {
              //     // Check if the phone number is valid and all digits are entered
              //     if (value &&
              //         phoneNumber.phoneNumber?.length ==
              //             phoneNumberController.text.length) {
              //       // Execute your logic when all digits are entered
              //       print(
              //           'Phone number entered completely: ${phoneNumberController.text}');
              //     }
              //   },
              // ),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                initialCountryCode: 'ET',
                onChanged: (phone) {
                  phoneNumb = phone.completeNumber;
                  print(phone.completeNumber);
                },
              ),
              SizedBox(
                height: 20,
              ),
              Obx((){
                if(authController.isLoading){
                  return CircularProgressIndicator();
                }else{
                  return Container();
                }
              }),
              SizedBox(height: 20,),
              Container(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Add your button's onPressed logic here
                    // Get.to(OTPScreen());
                    print("send to $phoneNumb");
                    authController.sendVerificationCode(phoneNumb);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 247, 89, 80),
                    padding: EdgeInsets.all(12), // Adjust the padding as needed
                    shadowColor: const Color.fromARGB(255, 19, 16, 16),
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Adjust the border radius as needed
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 240, 116,
                          107), // Set the color of the button outline
                      width: 2.0, // Set the width of the button outline
                    ),
                  ),

                 child: Text(
                    'Send Code',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, // Set the font size of the button text
                      fontWeight: FontWeight
                          .bold, // Set the font weight of the button text
                      // color: Color.fromARGB(255, 113, 185, 244), // Set the color of the button text
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
