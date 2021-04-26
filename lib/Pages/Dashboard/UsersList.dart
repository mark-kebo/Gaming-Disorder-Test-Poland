import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';

import 'CompletedFormAnswers.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class UsersList extends StatefulWidget {
  String id;

  UsersList(String id) {
    this.id = id;
  }

  @override
  State<StatefulWidget> createState() => _UsersListState(id);
}

class _UsersListState extends State<UsersList> {
  Map<String, String> _users = Map<String, String>();
  List<bool> _isUsersSuspicious = [];
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  String _name = "";
  String id;

  BorderRadius _borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.0),
      topRight: Radius.circular(16.0),
      bottomLeft: Radius.circular(16.0),
      bottomRight: Radius.circular(16.0));

  _UsersListState(String id) {
    this.id = id;
    _prepareViewData(id);
  }

  void _prepareViewData(String id) {
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc.data()["completedForms"] != null) {
                  var isHasForm = false;
                  for (var item in doc["completedForms"]) {
                    isHasForm = item["id"] == id;
                    if (isHasForm) {
                      _name = ProjectStrings.users + ": " + item["name"];
                      _users[doc["id"]] = doc["name"];
                      _isUsersSuspicious.add(item["isSuspicious"] ?? false);
                      continue;
                    }
                  }
                }
              })
            })
        .whenComplete(() => {setState(() {})});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ProjectStrings.projectName,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              _name.isEmpty ? ProjectStrings.statistics : _name,
              style: _titleTextStyle,
              textAlign: TextAlign.center,
            ),
            leading: BackButton(
              color: Colors.deepPurple,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: _users.length > 0
              ? Row(children: <Widget>[
                  _listView(),
                ])
              : Center(child: Text(ProjectStrings.emptyStatistycs))),
    );
  }

  Widget _listView() {
    return Expanded(
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _users.length,
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                  child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Container(
                  decoration: new BoxDecoration(
                      color: Colors.grey[200], borderRadius: _borderRadius),
                  child: GestureDetector(
                      child: ListTile(
                        title: new Text(_users[_users.keys.elementAt(index)]),
                        leading: _isUsersSuspicious[index]
                            ? Icon(Icons.error, color: Colors.redAccent)
                            : SizedBox(),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                      onTap: () => {
                            _navigateToStatistics(_users.keys.elementAt(index))
                          }),
                ),
              ));
            }));
  }

  void _navigateToStatistics(String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext ctx) =>
                CompletedFormAnswers.initById(id, this.id)));
  }
}
