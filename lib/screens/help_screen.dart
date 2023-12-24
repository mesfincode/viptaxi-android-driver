import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help"),),
      body: Container(
        padding: EdgeInsets.all(25),
        child: Text("Vip Taxi Driver app V-1.0.5",style: TextStyle(fontSize: 16),)),
    );
  }
}
