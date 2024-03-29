import 'package:csv/csv.dart';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/CompletedForm.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import "package:collection/collection.dart";

import 'UsersList.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class FormStatistics extends StatefulWidget {
  String id;

  FormStatistics(String id) {
    this.id = id;
  }

  @override
  State<StatefulWidget> createState() => _FormStatisticsState(id);
}

class _FormStatisticsState extends State<FormStatistics> {
  String id;
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  Map<dynamic, List<CompletedFormQuestion>> questions =
      Map<dynamic, List<CompletedFormQuestion>>();
  List<CSVCompletedFormModel> _completedFormsModels = [];
  String _name = "";

  _FormStatisticsState(String id) {
    this.id = id;
    _prepareViewData(id);
  }

  void _prepareViewData(String id) {
    List<CompletedFormQuestion> quest = <CompletedFormQuestion>[];
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  var completedCollection =
                      doc.data()[ProjectConstants.completedFormsCollectionName];
                  print('-------------$completedCollection');
                  if (completedCollection != null) {
                    completedCollection
                        .map((e) => CompletedFormModel(e))
                        .where((element) => element.id == id)
                        .toList()
                        .forEach((element) {
                      _completedFormsModels.add(CSVCompletedFormModel(
                          element,
                          doc.data()["name"],
                          doc.data()["id"],
                          doc.data()["stopTimerDate"],
                          doc.data()["startTimerDate"]));
                      _name = element.name;
                      quest.addAll(element.questions);
                    });
                  }
                });
              })
            })
        .whenComplete(() => {
              print('-------------FIN'),
              setState(() {
                questions = groupBy(quest, (obj) => obj.name);
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              _name.isEmpty ? ProjectStrings.statistics : _name,
              style: _titleTextStyle,
              textAlign: TextAlign.center,
            ),
            actions: [
              FlatButton(
                textColor: Colors.deepPurple,
                onPressed: () async {
                  _downloadCSV();
                },
                child: Text(ProjectStrings.formCSV),
              ),
              FlatButton(
                textColor: Colors.deepPurple,
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) => UsersList(id)));
                },
                child: Text(ProjectStrings.users),
              )
            ],
            leading: BackButton(
              color: Colors.deepPurple,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: questions.length > 0
              ? Row(children: <Widget>[
                  _listView(),
                ])
              : Center(child: Text(ProjectStrings.emptyStatistycs))),
    );
  }

  void _downloadCSV() async {
    List<List<dynamic>> rows = [];
    List<dynamic> titleRow = [];
    titleRow.add(ProjectStrings.users); //USER NAME
    titleRow.add("ID"); //USER ID
    titleRow.add(ProjectStrings.startTimer); //START TIMER
    titleRow.add(ProjectStrings.stopTimer); //STOP TIMER
    titleRow.add(ProjectStrings.form); //FORM NAME
    titleRow.add(ProjectStrings.timeInApp); //DATE LOG TO APP
    titleRow.add(ProjectStrings.userLocation); //LOCATION DATA
    titleRow.add(ProjectStrings.timeFromStartToAnswer); //START TO ANSWER TIME
    titleRow.add(ProjectStrings.fromPush); //IS OPEN FROM PUSH
    titleRow.add(ProjectStrings.isSuspicious); //IS SUSPICIOUS
    titleRow.add(ProjectStrings.points); //POINTS
    for (var element
        in _completedFormsModels.first.completedFormModel.questions) {
      String questionName =
          (element.name.isNotEmpty ? element.name : element.uuid)
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('#', '');
      titleRow.add(questionName); //QUESTION NAME
      titleRow.add("Dane dla: $questionName"); //QUESTION NAME
    }
    rows.add(titleRow);

    for (var item in _completedFormsModels) {
      List<dynamic> userRow = [];
      userRow.add(item.userName ?? ''); //USER NAME
      userRow.add(item.userId ?? ''); //USER ID
      userRow.add(item.startTimerDate ?? ''); //START TIMER
      userRow.add(item.stopTimerDate ?? ''); //STOP TIMER
      userRow.add(item.completedFormModel.name ?? ''); //FORM NAME
      userRow.add(item.completedFormModel.dateLogToApp ?? ''); //DATE LOG TO APP
      userRow.add(item.completedFormModel.locationData ?? ''); //LOCATION DATA
      userRow.add(item.completedFormModel.startToAnswerTime ??
          ''); //START TO ANSWER TIME
      userRow.add(
          item.completedFormModel.isOpenFromPush ?? ''); //IS OPEN FROM PUSH
      userRow.add(item.completedFormModel.isSuspicious ?? ''); //IS SUSPICIOUS
      userRow.add(item.completedFormModel.getPoints() ?? ''); //POINTS
      for (var element in item.completedFormModel.questions) {
        String questionOptions = element.selectedOptions
            .map((e) => e.text)
            .join(",\n")
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('#', '');
        userRow.add(questionOptions ?? ''); //QUESTION NAME
        String questionOptionsData = element.selectedOptions
            .map((e) => e.getOptionData())
            .join(",\n")
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('#', '');
        userRow.add(questionOptionsData ?? ''); //QUESTION NAME
      }
      rows.add(userRow);
    }

    print(titleRow);
    String csv = const ListToCsvConverter().convert(rows);
    new AnchorElement(href: "data:text/plain;charset=utf-8,$csv")
      ..setAttribute("download", "${_name + UniqueKey().toString()}.csv")
      ..click();
  }

  Widget _listView() {
    return Expanded(
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: questions.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Container(
                      height: 400.0,
                      decoration: new BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.deepPurple[100]))),
                      child: SfCircularChart(
                          legend: Legend(isVisible: true),
                          title: ChartTitle(
                              text: questions[
                                              questions.keys.elementAt(
                                                  index)] !=
                                          null &&
                                      questions[questions.keys.elementAt(index)]
                                          .first
                                          .name
                                          .isNotEmpty
                                  ? questions[questions.keys.elementAt(index)]
                                      .first
                                      .name
                                  : questions[questions.keys.elementAt(index)]
                                      .first
                                      .uuid),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <PieSeries<SelectedOption, String>>[
                            PieSeries<SelectedOption, String>(
                                dataSource: questions[
                                            questions.keys.elementAt(index)] !=
                                        null
                                    ? _chartDataSource(index)
                                    : [],
                                xValueMapper: (SelectedOption option, _) =>
                                    option.name,
                                yValueMapper: (SelectedOption option, _) =>
                                    option.count,
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true))
                          ])));
            }));
  }

  List<SelectedOption> _chartDataSource(int index) {
    List<SelectedOption> selectedOptions = [];
    Map<String, int> options = {};
    questions[questions.keys.elementAt(index)].forEach((quest) {
      quest.selectedOptions.forEach((i) => options[i.text] =
          options.containsKey(i.text) ? options[i.text] + 1 : 1);
    });
    options.forEach((key, value) {
      var selectedOption = SelectedOption();
      selectedOption.name = key;
      selectedOption.count = value;
      selectedOptions.add(selectedOption);
    });
    print(selectedOptions.toString());
    return selectedOptions;
  }
}
