import 'package:driver/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:driver/screens/home_screen.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/screens/otp_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    final storage = new FlutterSecureStorage();

   @override
  void initState() {
    super.initState();
    // Add any necessary initialization logic here
    // For example, you can add a delay and then navigate to the next screen

  


    Future.delayed(Duration(seconds: 2), () {
      // Replace `NextScreen()` with the screen you want to navigate to
      isLogedIn().then((value) => {
        if(value){

          isProfileCompleted().then((value) => {
              if(value){
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                )
              }else{
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                )
              }
          })
          
        }else{
            Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                )
        }
      });
    
    });
  }

  Future<bool> isLogedIn() async{
       String phone = await storage.read(key: 'phone')??'';
       String sessionToken = await storage.read(key: 'sessionToken')??'';
       if(phone.isNotEmpty && sessionToken.isNotEmpty){
        return true;
       }else{
          return false;
       }
           
  }
    Future<bool> isProfileCompleted() async{
       String profileStatus = await storage.read(key: 'profileStatus')??'';
       if(profileStatus=="isCompleted"){
        return true;
       }else{
          return false;
       }
           
  }
  @override
  Widget build(BuildContext context) {
        RequestController authController = Get.put(RequestController());

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(    
             child:   Image.asset(
              'assets/images/logo_bg_white.jpg', // Replace with your image path
              height: 200,
              width: 200,
            ),),
        ),
      ),
    );
  }
}