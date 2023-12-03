import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/controllers/profile_controller.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:driver/screens/help_screen.dart';
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
              child: Column(
            children: [
              CachedNetworkImage(
                imageUrl:
                    profileController.profilePic, // Replace with your image URL
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                  radius: 40, // Adjust the radius according to your preference
                ),
                placeholder: (context, url) => CircularProgressIndicator(color: Colors.red,),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Obx(() {
                return Text(
                  profileController.firstName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                );
              }),
            ],
          )),
         
          ListTile(
            title: Row(
              children: [
                Icon(Icons.help_outline_outlined),
                  SizedBox(width: 5,),
                Text("Help"),
              ],
            ),
            onTap: () {
              Get.to(HelpScreen());
            },
          ),
           ListTile(
            title: Obx(() {
              if (requestController.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.red,),
                );
              } else {
                return Row(children: [
                  Icon(Icons.logout_outlined),
                  SizedBox(width: 5,),
                  Text('LogOut')
                ],);
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
