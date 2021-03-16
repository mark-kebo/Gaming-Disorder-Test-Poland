import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Models/CompletedForm.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  CollectionReference _usersCollection = firestore.collection('users');
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];
  String _name = "";

  _FormStatisticsState(String id) {
    this.id = id;
    _prepareViewData(id);
  }

  void _prepareViewData(String id) {
    _usersCollection.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            setState(() {
              (doc["completedForms"] as List)
                  .map((e) => CompletedForm(e))
                  .where((element) => element.id == id)
                  .toList()
                  .forEach((element) {
                    _name = element.name;
                    questions.addAll(element.questions);
                  });
            });
            print(questions);
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard - Gaming Disorder Test Poland',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              _name,
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
          body: Row(children: <Widget>[
            _listView(),
          ])),
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
                      height: 300.0,
                      decoration: new BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.deepPurple[100]))),
                      child: SfCircularChart(
                          legend: Legend(isVisible: true),
                          title: ChartTitle(text: questions[index].name),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <PieSeries<String, String>>[
                            PieSeries<String, String>(
                                // Bind data source
                                dataSource: questions[index].selectedOptions,
                                
                                xValueMapper: (String option, _) =>
                                    option,
                                yValueMapper: (String option, _) =>
                                    1)
                          ])));
            }));
  }
}