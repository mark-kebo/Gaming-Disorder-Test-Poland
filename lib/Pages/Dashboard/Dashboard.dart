import 'package:myapp/NavigationBar/NavigationBar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String text = "Dashboard"; 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard - Gaming Disorder Test Poland',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: 
      new Scaffold(
          backgroundColor: Colors.white,
          body: Row(
            children: [
              NavigationBar(
                mainTouched: () {
                  setState(() {
                    text = "Dashboard";
                  });
                },
                createFormTouched: () {
                  setState(() {
                    text = "new form";
                  });
                }),
              Text(text)
            ],
          )
        ),
    );
  }
}