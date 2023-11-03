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
                  return OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Call API to verify OTP code
                      // Navigate to next screen
                      print(_otpCode);
                      authController.verityOtpAndSignin(widget.phoneNumber,_otpCode);
                    }
                  },
                  child: Text('Verify OTP'),
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
