import 'package:driver/controllers/network_controller.dart';
import 'package:driver/screens/edit_profile_screen.dart';
import 'package:driver/screens/home_screen2.dart';
import 'package:driver/screens/network_indicator_screen.dart';
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
  NetworkController networkController = Get.find();
  var subscription;
  @override
  void initState() {
    super.initState();
    subscription = networkController.isNetworkUsable.listen(
      (value) {
        if (value) {
          // Network is usable, perform online tasks

          init();
        } else {
          // Network is not usable, handle offline scenarios
        }
      },
    );
    // Add any necessary initialization logic here
    // For example, you can add a delay and then navigate to the next screen
    init();
  }

  @override
  void dispose() {
    subscription.cancel();

    // networkController.dispose();
    super.dispose();
  }

  init() async {
    bool hasUsableNetwork = await networkController.hasUsableNetwork();

    if (hasUsableNetwork) {
      subscription.cancel();

      Future.delayed(Duration(seconds: 2), () {
        // Replace `NextScreen()` with the screen you want to navigate to
        isLogedIn().then((value) async => {
              if (value)
                {
                  isProfileCompleted().then((value) => {
                        if (value)
                          {
                            if (mounted)
                              {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen2()),
                                )
                              }
                          }
                        else
                          {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfileScreen()),
                            )
                          }
                      })
                }
              else
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  )
                }
            });
      });
    } else {
      Future.delayed(Duration(seconds: 2), () {
        Get.to(NetworkIndicatorScreen());
      });

      //  Navigator.pushReplacement(
      //               context,
      //               MaterialPageRoute(builder: (context) => LoginScreen()),
      //             )
    }
  }

  Future<bool> isLogedIn() async {
    try {
      String phone = await storage.read(key: 'phone') ?? '';
      String sessionToken = await storage.read(key: 'sessionToken') ?? '';
      if (phone.isNotEmpty && sessionToken.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> isProfileCompleted() async {
    String profileStatus = await storage.read(key: 'profileStatus') ?? '';
    if (profileStatus == "isCompleted") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    RequestController authController = Get.put(RequestController());
    NetworkController networkController = Get.put(NetworkController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_bg_white.jpg', // Replace with your image path
                height: 200,
                width: 200,
              ),
              Text(
                "Vip Taxi Ethiopia Driver App",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
          height: 5,
          margin: EdgeInsets.only(bottom: 10),
          child: LinearProgressIndicator(
            color: Colors.red,
          )),
    );
  }
}
