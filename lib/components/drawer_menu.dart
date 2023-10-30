import 'package:driver/controllers/profile_controller.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({
    super.key,
    required this.drawerWidth,
    required this.driverName,
  });

  final double drawerWidth;
  final String driverName;

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {

  @override
  Widget build(BuildContext context) {
    RequestController requestController = Get.find();
    ProfileController profileController = Get.find();
    return Drawer(
      width: widget.drawerWidth,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            // ),
            child:Obx((){
             return  Text(
              profileController.firstName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            );
            })
          ),
          ListTile(
            title:Obx(() {
              if(requestController.isLoading){
                return Center(child: CircularProgressIndicator(),);
              }else{
                return  Text('LogOut');
              }
            }),
            onTap: () async {
              // Handle item 1 tap
              // SharedPreferences preferences =
              //     await SharedPreferences.getInstance();
              // preferences.remove('driverName');
                requestController.logout();
              // Get.to(LoginScreen());
            },
          ),
        
        ],
      ),
    );
  }
}