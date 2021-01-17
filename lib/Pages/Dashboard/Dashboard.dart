import 'package:myapp/NavigationBar/NavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Pages/Dashboard/EditForm.dart';
import 'package:myapp/Helpers/Alert.dart';

enum DashboardState { main, forms, statistics, settings }

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardState state = DashboardState.main;
  double contentPadding = 32;
  CollectionReference forms = firestore.collection('forms');
  TextStyle titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  Radius listElementCornerRadius = const Radius.circular(16.0);
  final AlertController _alertController = AlertController();

  @override
  Widget build(BuildContext context) {
    var positioned = Positioned(
        top: contentPadding,
        left: contentPadding + 100,
        right: contentPadding,
        bottom: contentPadding,
        child: appStack());
    return MaterialApp(
        title: 'Dashboard - Gaming Disorder Test Poland',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
          floatingActionButton: state == DashboardState.forms
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    print("new form pressed");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext ctx) => EditForm()));
                  },
                )
              : null,
          body: Stack(
            children: [
              positioned,
              NavigationBar(mainTouched: () {
                setState(() {
                  state = DashboardState.main;
                });
              }, formsTouched: () {
                setState(() {
                  state = DashboardState.forms;
                });
              }, statisticsTouched: () {
                setState(() {
                  state = DashboardState.statistics;
                });
              }, settingsTouched: () {
                setState(() {
                  state = DashboardState.settings;
                });
              })
            ],
          ),
        ));
  }

  Widget appStack() {
    switch (state) {
      case DashboardState.main:
        {
          return Text("Gaming Disorder Test Poland", style: titleTextStyle);
        }
        break;
      case DashboardState.forms:
        {
          return formsStack();
        }
        break;
      case DashboardState.statistics:
        {
          return Text("Statistics", style: titleTextStyle);
        }
        break;
      case DashboardState.settings:
        {
          return Text("Settings", style: titleTextStyle);
        }
        break;
      default:
        {
          return null;
        }
        break;
    }
  }

  Stack formsStack() {
    return Stack(
      children: [
        Text("All Forms", style: titleTextStyle),
        Positioned(
            top: contentPadding * 2,
            left: 0,
            right: 0,
            bottom: 0,
            child: StreamBuilder<QuerySnapshot>(
              stream: forms.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Something went wrong',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return formsList(snapshot);
              },
            )),
      ],
    );
  }

  ListView formsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
          onTap: () {
            print("table element tapped");
          },
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              height: 64.0,
              decoration: new BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: new BorderRadius.only(
                      topLeft: listElementCornerRadius,
                      topRight: listElementCornerRadius,
                      bottomLeft: listElementCornerRadius,
                      bottomRight: listElementCornerRadius)),
              child: ListTile(
                  title: new Text(document.data()['name']),
                  subtitle: new Text(document.data()['description']),
                  trailing: dropdownCellMenu(document.id)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget dropdownCellMenu(String id) {
    return DropdownButton<String>(
      icon: Icon(Icons.more_vert),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.grey[200],
      ),
      onChanged: (String newValue) {
        if (newValue == 'Edit') {
        } else {
          _deleteForm(id);
        }
      },
      items: <String>['Edit', 'Delete']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void _deleteForm(String id) {
    _alertController.showMessageDialogWithAction(
        context, "Delete form", "Are you sure you want to delete this form?",
        () async {
      forms.doc(id).delete().then((value) => print("User Deleted")).catchError(
          (error) => _alertController.showMessageDialog(
              context, "Failed to delete form", error));
    });
  }
}
