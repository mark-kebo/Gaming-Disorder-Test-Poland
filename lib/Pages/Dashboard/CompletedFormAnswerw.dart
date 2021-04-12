import 'package:flutter/material.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/CompletedForm.dart';
import 'package:myapp/Helpers/Alert.dart';

// ignore: must_be_immutable
class CompletedFormAnswers extends StatefulWidget {
  CompletedFormModel _formModel;

  CompletedFormAnswers(CompletedFormModel formModel) {
    this._formModel = formModel;
  }

  @override
  State<StatefulWidget> createState() => _CompletedFormAnswersState(_formModel);
}

class _CompletedFormAnswersState extends State<CompletedFormAnswers> {
  double _formPadding = 24.0;
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  CompletedFormModel _formModel;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AlertController alertController = AlertController();

  _CompletedFormAnswersState(CompletedFormModel formModel) {
    this._formModel = formModel;
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
            body: Padding(
                padding: EdgeInsets.all(_formPadding), child: _questionsList()),
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: BackButton(
                color: Colors.deepPurple,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                _formModel.name,
                style: _titleTextStyle,
                textAlign: TextAlign.center,
              ),
            )));
  }

  Widget _questionsList() {
    var questions = _formModel.questions;
    print(questions.first.name);
    return ListView.builder(
        itemCount: questions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title:
                  Text((index + 1).toString() + ". " + questions[index].name),
              subtitle: Text(questions[index].selectedOptions.join(", ")));
        });
  }
}
