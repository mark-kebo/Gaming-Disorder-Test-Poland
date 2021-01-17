import 'package:flutter/material.dart';
import 'package:myapp/Pages/Login/Login.dart';
import 'package:myapp/Pages/Dashboard/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  var password = prefs.getString('password');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  if (email != null || email != "" || password != null) {
    try {
      User user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      user != null
          ? runApp(MaterialApp(home: Dashboard()))
          : runApp(MaterialApp(home: Login()));
    } catch (error) {
      runApp(MaterialApp(home: Login()));
    }
  } else {
    runApp(MaterialApp(home: Login()));
  }
}
