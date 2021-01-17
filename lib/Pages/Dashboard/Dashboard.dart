import 'package:myapp/NavigationBar/NavigationBar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isDashboard = true; 
  double contentPadding = 32;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard - Gaming Disorder Test Poland',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold (
        floatingActionButton: isDashboard ? null : FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.deepPurple,
          onPressed: () {
            print("add new form action");
          },),
        body: Stack(
        children: [
          Positioned(
            top: contentPadding,
            left: contentPadding + 100,
            right: contentPadding,
            bottom: contentPadding,
            child: isDashboard ? 
              Text("Gaming Disorder Test Poland",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.deepPurple)
              ):
              Stack (children: [
                Text("All Forms",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.deepPurple)
                ),
                Positioned(
                  top: contentPadding * 2,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return new GestureDetector(
                        onTap: () {
                          print("tapped");
                        },
                        child: new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Container(
                            color: Colors.grey,
                            height: 64.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],)
          ),
          NavigationBar(
            mainTouched: () {
              setState(() {
                isDashboard = true;
              });
            },
            createFormTouched: () {
              setState(() {
                isDashboard = false;
              });
            }
          )
        ],),
      )
    );
  }
}