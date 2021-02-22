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
  CollectionReference _userGroups = firestore.collection('user_groups');
  CollectionReference _users = firestore.collection('users');
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  TextStyle _subtitleTextStyle = TextStyle(
      fontWeight: FontWeight.normal, fontSize: 24, color: Colors.deepPurple);
  final AlertController _alertController = AlertController();
  BorderRadius _borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.0),
      topRight: Radius.circular(16.0),
      bottomLeft: Radius.circular(16.0),
      bottomRight: Radius.circular(16.0));
  EdgeInsets _boxPadding =
      EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16);

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
                            builder: (BuildContext ctx) => EditForm("")));
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
          return mainScreenStack();
        }
        break;
      case DashboardState.forms:
        {
          return formsStack();
        }
        break;
      case DashboardState.statistics:
        {
          return Text("Statistics", style: _titleTextStyle);
        }
        break;
      case DashboardState.settings:
        {
          return Text("Settings", style: _titleTextStyle);
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
        Text("All Forms", style: _titleTextStyle),
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

  Widget mainScreenStack() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(),
            ),
            Expanded(
                flex: 4,
                child: Column(children: [
                  Expanded(child: _groupsWidget()),
                  Expanded(child: _usersWidget())
                ]))
          ],
        )
      ],
    );
  }

  Widget _groupsWidget() {
    return new Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: _boxPadding,
        decoration: new BoxDecoration(
            color: Colors.grey[100], borderRadius: _borderRadius),
        child: Column(
          children: [
            Text("User groups", style: _subtitleTextStyle),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: _userGroups.snapshots(),
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
                return _groupsList(snapshot);
              },
            ))
          ],
        ));
  }

  Widget _usersWidget() {
    return new Container(
        margin: EdgeInsets.only(top: 8),
        padding: _boxPadding,
        decoration: new BoxDecoration(
            color: Colors.grey[100], borderRadius: _borderRadius),
        child: Column(
          children: [
            Text("All users", style: _subtitleTextStyle),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: _users.snapshots(),
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
                return _usersList(snapshot);
              },
            ))
          ],
        ));
  }

  ListView formsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              height: 64.0,
              decoration: new BoxDecoration(
                  color: Colors.grey[200], borderRadius: _borderRadius),
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

  ListView _groupsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              height: 48.0,
              decoration: new BoxDecoration(
                  color: Colors.grey[200], borderRadius: _borderRadius),
              child: ListTile(
                  title: new Text(document.data()['name']),
                  trailing: dropdownCellMenu(document.id)),
            ),
          ),
        );
      }).toList(),
    );
  }

  ListView _usersList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
            child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Container(
            height: 48.0,
            decoration: new BoxDecoration(
                color: Colors.grey[200], borderRadius: _borderRadius),
            child: ListTile(
              title: new Text(document.data()['name']),
            ),
          ),
        ));
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
          _editForm(id);
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

  void _editForm(String id) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) => EditForm(id)));
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
