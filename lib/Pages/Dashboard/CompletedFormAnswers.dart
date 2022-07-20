import 'package:flutter/material.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/CompletedForm.dart';
import 'package:myapp/Helpers/Alert.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class CompletedFormAnswers extends StatefulWidget {
  CompletedFormModel _formModel;
  String _userId;
  String _formId;
  String _userName = "";

  CompletedFormAnswers(CompletedFormModel formModel, String userName) {
    this._formModel = formModel;
    this._userName = userName;
  }

  CompletedFormAnswers.initById(String userId, String formId) {
    this._userId = userId;
    this._formId = formId;
  }

  @override
  State<StatefulWidget> createState() => _formModel != null
      ? _CompletedFormAnswersState(_formModel, _userName)
      : _CompletedFormAnswersState.initById(_userId, _formId);
}

class _CompletedFormAnswersState extends State<CompletedFormAnswers> {
  double _formPadding = 24.0;
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  CompletedFormModel _formModel;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AlertController alertController = AlertController();
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  bool _isShowLoading = true;
  String _userName = "";

  _CompletedFormAnswersState(CompletedFormModel formModel, String userName) {
    this._formModel = formModel;
    this._userName = userName;
    _isShowLoading = false;
  }

  _CompletedFormAnswersState.initById(String userId, String formId) {
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["id"] == userId &&
                    doc[ProjectConstants.completedFormsCollectionName] !=
                        null) {
                  doc[ProjectConstants.completedFormsCollectionName]
                      .map((e) => CompletedFormModel(e))
                      .toList()
                      .forEach((element) {
                    if (element != null) {
                      print(element.id);
                      if (element.id == formId) {
                        this._userName = doc["name"];
                        this._formModel = element;
                      }
                    }
                  });
                }
              })
            })
        .whenComplete(() => {
              setState(() {
                _isShowLoading = false;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: ProjectStrings.projectName,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
            key: _scaffoldKey,
            body: _isShowLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.all(_formPadding),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _messageTextField(),
                      _suspiciousTextField(),
                      _otherDataList(),
                      _checkList(),
                      _questionsList()
                    ])),
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: BackButton(
                color: Colors.deepPurple,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                _formModel != null
                    ? _formModel.name + " - " + _userName
                    : ProjectStrings.statistics,
                style: _titleTextStyle,
                textAlign: TextAlign.center,
              ),
            )));
  }

  Widget _suspiciousTextField() {
    return _formModel.isSuspicious
        ? Text(ProjectStrings.isSuspicious,
            style: TextStyle(color: Colors.redAccent))
        : SizedBox();
  }

  Widget _messageTextField() {
    bool isNeedMessage = _formModel.message.isNotEmpty &&
        _formModel.message != "null" &&
        _formModel.isSuspicious;
    return isNeedMessage
        ? Text(
            _formModel.message +
                "  (" +
                _formModel.getPoints().toString() +
                ProjectStrings.points +
                ")",
            style: TextStyle(color: Colors.redAccent))
        : SizedBox();
  }

  Widget _questionsList() {
    var questions = _formModel.questions;
    print(questions.first.name);
    return Expanded(
        child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  title: Text((index + 1).toString() +
                      ". " +
                      (questions[index].name.isNotEmpty
                          ? questions[index].name
                          : questions[index].uuid)),
                  subtitle: Text(questions[index]
                      .selectedOptions
                      .map((e) => e.getFullText())
                      .join(",\n")));
            }));
  }

  Widget _otherDataList() {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: EdgeInsets.only(top: _formPadding, bottom: _formPadding),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ProjectStrings.userLocation + _formModel.locationData,
                      style: TextStyle(color: Colors.black)),
                  Text(
                      ProjectStrings.fromPush +
                          (_formModel.isOpenFromPush ? "tak" : "nie"),
                      style: TextStyle(color: Colors.black)),
                  Text(
                      ProjectStrings.timeFromStartToAnswer +
                          _formModel.startToAnswerTime,
                      style: TextStyle(color: Colors.black)),
                  Text(ProjectStrings.timeInApp + _formModel.dateLogToApp,
                      style: TextStyle(color: Colors.black))
                ])));
  }

  Widget _checkList() {
    print(_formModel.checkList.dateTime);
    return _formModel.checkList != null &&
            _formModel.checkList.dateTime != null &&
            _formModel.checkList.options != null &&
            _formModel.checkList.name != null
        ? ListTile(
            title: Text(ProjectStrings.checklist +
                " - " +
                (_formModel.checkList.name ?? "") +
                " (" +
                DateFormat(ProjectConstants.dateFormat)
                    .format(_formModel.checkList.dateTime) +
                ") "),
            subtitle: Text(_formModel.checkList.options.toString()))
        : SizedBox();
  }
}
