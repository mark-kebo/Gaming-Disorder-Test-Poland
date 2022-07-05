import 'package:flutter/material.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/NavigationBar/CompanyName.dart';
import 'package:myapp/NavigationBar/NavBar.dart';
import 'package:myapp/Pages/Login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/Helpers/Alert.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class NavigationCustomBar extends StatefulWidget {
  final Function mainTouched;
  final Function formsTouched;
  final Function researchProgrammesTouched;
  final Function statisticsTouched;
  final Function settingsTouched;

  NavigationCustomBar(
      {this.mainTouched,
      this.formsTouched,
      this.researchProgrammesTouched,
      this.settingsTouched,
      this.statisticsTouched});

  @override
  State<StatefulWidget> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationCustomBar> {
  final AlertController alertController = AlertController();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: 100.0,
        color: Colors.grey[850],
        child: Stack(
          children: [
            CompanyName(),
            Align(
                alignment: Alignment.center,
                child: NavBar(
                  formsTouched: () {
                    widget.formsTouched();
                  },
                  mainTouched: () {
                    widget.mainTouched();
                  },
                  researchProgrammesTouched: () {
                    widget.researchProgrammesTouched();
                  },
                  statisticsTouched: () {
                    widget.statisticsTouched();
                  },
                  settingsTouched: () {
                    widget.settingsTouched();
                  },
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: NavBarItem(
                icon: Icons.logout,
                active: false,
                touched: () {
                  alertController.showMessageDialogWithAction(
                      context,
                      ProjectStrings.logout,
                      ProjectStrings.logoutQuestion, () async {
                    _auth.signOut();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove(ProjectConstants.prefsEmail);
                    prefs.remove(ProjectConstants.prefsPassword);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext ctx) => Login()));
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
