import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/CompletedForm.dart';

import 'CompletedFormAnswers.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class UserStatistics extends StatefulWidget {
  String id;

  UserStatistics(String id) {
    this.id = id;
  }

  @override
  State<StatefulWidget> createState() => _UserStatisticsState(id);
}

class _UserStatisticsState extends State<UserStatistics> {
  List<CompletedFormModel> _forms = <CompletedFormModel>[];
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

  _UserStatisticsState(String id) {
    this.id = id;
    _prepareViewData(id);
  }

  void _prepareViewData(String id) {
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["id"] == id) {
                  setState(() {
                    (doc[ProjectConstants.completedFormsCollectionName] as List)
                        .map((e) => CompletedFormModel(e))
                        .toList()
                        .forEach((element) {
                      _forms.add(element);
                    });
                  });
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
          body: _forms.length > 0
              ? Row(children: <Widget>[
                  _listView(),
                ])
              : Center(child: Text(ProjectStrings.emptyUserStatistycs))),
    );
  }

  Widget _listView() {
    return Expanded(
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _forms.length,
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                  child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Container(
                  decoration: new BoxDecoration(
                      color: Colors.grey[200], borderRadius: _borderRadius),
                  child: GestureDetector(
                      child: ListTile(
                        title: new Text(_forms[index].name),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                      onTap: () => {_navigateToStatistics(_forms[index])}),
                ),
              ));
            }));
  }

  void _navigateToStatistics(CompletedFormModel completedFormModel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext ctx) =>
                CompletedFormAnswers(completedFormModel)));
  }
}
