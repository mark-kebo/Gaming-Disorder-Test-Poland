import 'package:myapp/NavigationBar/NavigationBar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard - Gaming Disorder Test Poland',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: 
      new Scaffold(
          backgroundColor: Colors.white,
          body: DashboardPage(),
        ),
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
    return Row(
      children: [
        Container(
          child: NavigationBar()
        ),
        Container(
          child: Text('Some content'),
        ),
      ],
    );
    //   appBar: AppBar(
    //     title: Text('Gaming Disorder Test Poland - Dashboard'),
    //     backgroundColor: Colors.blue,
    //     actions: <Widget>[ 
    //       FlatButton(
    //         textColor: Colors.white,
    //         onPressed: () async {
    //           _auth.signOut();
    //           SharedPreferences prefs = await SharedPreferences.getInstance();
    //           prefs.remove('email');
    //           prefs.remove('password');
    //           Navigator.pushReplacement(context,
    //               MaterialPageRoute(builder: (BuildContext ctx) => Login()));
    //         },
    //         child: Text('Logout'),
    //       ),
    //     ]
    //   ),
    // );
  }
}