import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:driver/controllers/request_controller.dart';

class OTPScreen extends StatefulWidget {
   final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  String _otpCode = '';
  final _otpFocusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    // _otpFocusNode.requestFocus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RequestController authController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter the 6-digit code sent to your phone:',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                // focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter OTP Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the OTP code';
                  } else if (value.length != 6) {
                    return 'Please enter a valid 6-digit OTP code';
                  }
                  return null;
                },
                onSaved: (value) {
                  _otpCode = value!;
                },
              ),
              SizedBox(height: 16.0),
               
              SizedBox(height: 20,),
              Center(
                child:
                
                  Obx((){
                if(authController.isLoading){
                  return CircularProgressIndicator();
                }else{
                  return  Container(
                    width: double.infinity,
                    child: OutlinedButton(
                    onPressed: () {
                       if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Call API to verify OTP code
                        // Navigate to next screen
                        print(_otpCode);
                        authController.verityOtpAndSignin(widget.phoneNumber,_otpCode);
                      }
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
                      'Verify Otp',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16, // Set the font size of the button text
                        fontWeight: FontWeight
                            .bold, // Set the font weight of the button text
                        // color: Color.fromARGB(255, 113, 185, 244), // Set the color of the button text
                      ),
                    ),
                                  ),
                  );
                }
              }),
                 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
