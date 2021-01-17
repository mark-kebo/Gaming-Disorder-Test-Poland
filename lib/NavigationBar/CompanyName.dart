import 'package:flutter/material.dart';

class CompanyName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      child: Center(
          child: Stack(
        children: [
          Center(child: Icon(Icons.dashboard, color: Colors.deepPurple[400])),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Text('Dashboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple[200],
                    fontSize: 14.0,
                  )))
        ],
      )),
    );
  }
}
