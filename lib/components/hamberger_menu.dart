

import 'package:flutter/material.dart';

class HambergerMenu extends StatelessWidget {
  const HambergerMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      left: 8,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                    0.2), // Set the shadow color and opacity
                spreadRadius:
                    2, // Set the spread radius of the shadow
                blurRadius:
                    5, // Set the blur radius of the shadow
                offset: Offset(
                    0, 2), // Set the offset of the shadow
              ),
            ],
          ),
          child: Builder(
            builder: (context) => IconButton(
              iconSize: 25,
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
      ),
    );
  }
}