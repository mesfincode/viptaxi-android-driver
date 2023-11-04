import 'package:flutter/material.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  NotificationDetailsScreen(this.title, this.body, this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              body ?? '',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              data.toString(),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}