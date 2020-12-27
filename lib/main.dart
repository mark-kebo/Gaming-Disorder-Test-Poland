import 'package:flutter/material.dart';
import 'package:myapp/Pages/Login/Login.dart';
import 'package:myapp/Pages/Dashboard/Dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance; 
    return MaterialApp(
      title: 'Dashboard - Gaming Disorder Test Poland',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _auth.currentUser != null ? DashboardPage() : LoginPage(),
    );
  }
}