import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/CompletedForm.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import "package:collection/collection.dart";

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
                        .map((e) => CompletedForm(e))
                        .where((element) => element.id == id)
                        .toList()
                        .forEach((element) {
                      _name = element.name;
                      quest.addAll(element.questions);
                    });
                  }
                });
              })
            })
        .whenComplete(() => {
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
                              bottom:
                                  BorderSide(color: Colors.deepPurple[100]))),
                      child: SfCircularChart(
                          legend: Legend(isVisible: true),
                          title: ChartTitle(
                              text: questions[
                                          questions.keys.elementAt(index)] !=
                                      null
                                  ? questions[questions.keys.elementAt(index)]
                                      .first
                                      .name
                                  : ""),
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
      quest.selectedOptions.forEach((i) =>
          options['$i'] = options.containsKey('$i') ? options['$i'] + 1 : 1);
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
