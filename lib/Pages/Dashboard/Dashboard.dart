import 'package:flutter/material.dart';
import 'package:myapp/Pages/Login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard - Gaming Disorder Test Poland',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: DashboardPage(),
    );
  }
}

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
      appBar: AppBar(
        title: Text('Gaming Disorder Test Poland - Dashboard'),
        backgroundColor: Colors.red,
        actions: <Widget>[ 
          FlatButton(
            textColor: Colors.white,
            onPressed: () async {
              _auth.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('email');
              prefs.remove('password');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext ctx) => Login()));
            },
            child: Text('Logout'),
          ),
        ]
      ),
    );
  }
}