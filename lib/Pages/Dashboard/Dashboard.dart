import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/NavigationBar/NavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Pages/Dashboard/EditForm.dart';
import 'package:myapp/Pages/Dashboard/EditGroup.dart';
import 'package:myapp/Helpers/Alert.dart';
import 'package:myapp/Pages/Dashboard/FormStatistics.dart';

enum DashboardState { main, forms, statistics, settings }

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardState state = DashboardState.main;
  double contentPadding = 32;
  CollectionReference forms = firestore.collection(ProjectConstants.formsCollectionName);
  CollectionReference _userGroups = firestore.collection(ProjectConstants.groupsCollectionName);
  CollectionReference _users = firestore.collection(ProjectConstants.usersCollectionName);
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
        title: ProjectStrings.projectName,
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
                    _editForm("");
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
          return _statisticsStack();
        }
        break;
      case DashboardState.settings:
        {
          return Text(ProjectStrings.settings, style: _titleTextStyle);
        }
        break;
      default:
        {
          return null;
        }
        break;
    }
  }

  Stack _statisticsStack() {
    return Stack(children: [
      Text(ProjectStrings.statistics, style: _titleTextStyle),
      Positioned(
          top: contentPadding * 2,
          left: 0,
          right: 0,
          bottom: 0,
          child: StreamBuilder<QuerySnapshot>(
            stream: forms.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text(ProjectStrings.anyError,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return statisticsFormsList(snapshot);
            },
          )),
    ]);
  }

  Stack formsStack() {
    return Stack(
      children: [
        Text(ProjectStrings.allForms, style: _titleTextStyle),
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
                      child: Text(ProjectStrings.anyError,
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
            Row(children: [
              Expanded(
                  flex: 9,
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(ProjectStrings.userGroups, style: _subtitleTextStyle))),
              Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            print("add group pressed");
                            _editGroup("");
                          })))
            ]),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: _userGroups.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(ProjectStrings.anyError,
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
            Text(ProjectStrings.allUsers, style: _subtitleTextStyle),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: _users.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(ProjectStrings.anyError,
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

  ListView statisticsFormsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
          child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Container(
                height: 64.0,
                decoration: new BoxDecoration(
                    color: Colors.grey[200], borderRadius: _borderRadius),
                child: GestureDetector(
                    child: ListTile(
                        title: new Text(document.data()['name']),
                        subtitle: new Text(document.data()['description'])),
                    onTap: () => {_navigateToFormStatistics(document.id)}),
              )),
        );
      }).toList()
    );
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
                  trailing: dropdownCellMenu(
                      onDelete: () => {_deleteForm(document.id)},
                      onEdit: () => {_editForm(document.id)})),
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
                  trailing: dropdownCellMenu(
                      onDelete: () => {_deleteGroup(document.id)},
                      onEdit: () => {_editGroup(document.id)})),
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

  Widget dropdownCellMenu({Function onDelete, Function onEdit}) {
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
        if (newValue == ProjectStrings.edit) {
          onEdit();
        } else {
          onDelete();
        }
      },
      items: <String>[ProjectStrings.edit, ProjectStrings.delete]
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

void _navigateToFormStatistics(String id) {
      Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) => FormStatistics(id)));
}

  void _editForm(String id) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) => EditForm(id)));
  }

  void _editGroup(String id) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) => EditGroup(id)));
  }

  void _deleteForm(String id) {
    _alertController.showMessageDialogWithAction(
        context, ProjectStrings.deleteForm, ProjectStrings.deleteFormQuestion,
        () async {
      forms.doc(id).delete().then((value) => print("User Deleted")).catchError(
          (error) => _alertController.showMessageDialog(
              context, ProjectStrings.deleteFormError, error));
    });
  }

  void _deleteGroup(String id) {
    _alertController.showMessageDialogWithAction(
        context, ProjectStrings.deleteGroup, ProjectStrings.deleteGroupQuestion,
        () async {
      _userGroups
          .doc(id)
          .delete()
          .then((value) => print("Group Deleted"))
          .catchError((error) => _alertController.showMessageDialog(
              context, ProjectStrings.deleteGroupError, error));
    });
  }
}
