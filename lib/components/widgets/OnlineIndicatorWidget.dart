import 'dart:async';

import 'package:driver/constants.dart';
import 'package:driver/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OnlineIndicatorWidget extends StatefulWidget {
  const OnlineIndicatorWidget({super.key});

  @override
  State<OnlineIndicatorWidget> createState() => _OnlineIndicatorWidgetState();
}

class _OnlineIndicatorWidgetState extends State<OnlineIndicatorWidget> {
    late StreamSubscription<DatabaseEvent> subscription;

  bool _isOnline = false;
  void setOnline() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/presence').update({
      "status": "online",
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      // Data saved successfully!
      sharedPref.setBool(WANT_TO_BE_ONLINE, true);
      setState(() {
        _isOnline = true;
      });
      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  void setOffline() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';

    driverRef.child('/${driverId}/presence').update({
      "status": "offline",
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      // Data saved successfully!
      sharedPref.setBool(WANT_TO_BE_ONLINE, false);
      setState(() {
        _isOnline = false;
      });
      print("update success");
    }).catchError((error) {
      // The write failed...
      print("update error");
    });
  }

  void getOnlineStatus() async {
    String driverId = await secureStorage.read(key: 'driverId') ?? '';
   subscription =   driverRef
        .child('/${driverId}/presence')
        .onValue
        .listen((DatabaseEvent event) {
      dynamic data = event.snapshot.value;
      if (data != null) {
        dynamic status = data['status'];
        if (status == "online") {
          setState(() {
            _isOnline = true;
          });
        } else {
          setState(() {
            _isOnline = false;
          });
        }
      }
    });
  }

  void _toggleStatus() {
    // setOffline() ;
    if (_isOnline) {
      setOffline();
    } else {
      setOnline();
    }
    // setState(() {
    //   _isOnline = !_isOnline;
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    getOnlineStatus();
    super.initState();
  }
@override
  void dispose() {
    // TODO: implement dispose
     subscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 40,
        right: 10,
        child: InkWell(
          onTap: _toggleStatus,
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20.0),
              color: _isOnline ? Colors.green : Colors.red,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.check : Icons.close,
                  color: Colors.white,
                ),
                SizedBox(width: 8.0),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
