import 'package:flutter/material.dart';
import 'package:myapp/src/CompanyName.dart';
import 'package:myapp/src/NavBar.dart';
import 'package:myapp/Pages/Login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/Helpers/Alert.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class NavigationBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  final AlertController alertController = AlertController();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: 100.0,
        color: Color(0xff333951),
        child: Stack(
        children: [
          CompanyName(),
          Align(
            alignment: Alignment.center,
            child: NavBar()),
          Align(
            alignment: Alignment.bottomCenter,
            child: NavBarItem(
              icon: Icons.logout,
              active: false,
              touched: () {
                alertController.showMessageDialogWithAction(context, 
                "Log out", 
                "Are you sure you want to log out?", 
                () async {
                  _auth.signOut();
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove('email');
                  prefs.remove('password');
                  Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext ctx) => Login()));
                });
              },
            ),
          )
          ],
        ),
      ),
    );
  }
}