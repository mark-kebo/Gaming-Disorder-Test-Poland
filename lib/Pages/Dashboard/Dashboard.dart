import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => DashboardScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Text('Dashboard', style: Theme
              .of(context)
              .textTheme
              .headline4)
    );
  }
}