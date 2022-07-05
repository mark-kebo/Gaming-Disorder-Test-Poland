import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/Questionary.dart';
import 'package:myapp/NavigationBar/NavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Pages/Dashboard/EditForm.dart';
import 'package:myapp/Pages/Dashboard/EditGroup.dart';
import 'package:myapp/Helpers/Alert.dart';
import 'package:myapp/Pages/Dashboard/EditResearchProgram.dart';
import 'package:myapp/Pages/Dashboard/FormStatistics.dart';
import 'package:myapp/Pages/Dashboard/UserStatistics.dart';

enum DashboardState { main, forms, researchProgrammes, statistics, settings }

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardState state = DashboardState.main;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  double contentPadding = 32;
  CollectionReference forms =
      firestore.collection(ProjectConstants.formsCollectionName);
  CollectionReference _userGroups =
      firestore.collection(ProjectConstants.groupsCollectionName);
  CollectionReference _users =
      firestore.collection(ProjectConstants.usersCollectionName);
  CollectionReference _settings =
      firestore.collection(ProjectConstants.settingsCollectionName);
  CollectionReference _researchProgrammes =
      firestore.collection(ProjectConstants.researchProgrammesCollectionName);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final AlertController alertController = AlertController();
  String userCollectionId = "";
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
    _settings.doc(ProjectConstants.settingsContactCollectionName).get().then(
        (value) => {
              _emailController.text = value["email"],
              _phoneController.text = value["phone"]
            });

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
          floatingActionButton: state == DashboardState.forms ||
                  state == DashboardState.settings ||
                  state == DashboardState.researchProgrammes
              ? FloatingActionButton(
                  child: Icon(state == DashboardState.forms ||
                          state == DashboardState.researchProgrammes
                      ? Icons.add
                      : Icons.done),
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    if (state == DashboardState.forms) {
                      print("new form pressed");
                      _editForm("");
                    } else if (state == DashboardState.researchProgrammes) {
                      _editResearchProgram("");
                    } else if (state == DashboardState.settings) {
                      _saveSettings();
                    }
                  },
                )
              : null,
          body: Stack(
            children: [
              positioned,
              NavigationCustomBar(mainTouched: () {
                setState(() {
                  state = DashboardState.main;
                });
              }, formsTouched: () {
                setState(() {
                  state = DashboardState.forms;
                });
              }, researchProgrammesTouched: () {
                setState(() {
                  state = DashboardState.researchProgrammes;
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
      case DashboardState.researchProgrammes:
        {
          return researchProgrammesStack();
        }
        break;
      case DashboardState.statistics:
        {
          return _statisticsStack();
        }
        break;
      case DashboardState.settings:
        {
          return _settingsStack();
        }
        break;
      default:
        {
          return null;
        }
        break;
    }
  }

  Stack _settingsStack() {
    return Stack(children: [
      Text(ProjectStrings.settings, style: _titleTextStyle),
      Positioned(
        top: contentPadding * 2,
        left: 0,
        right: 0,
        bottom: 0,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: _boxPadding,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(ProjectStrings.contact,
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.start))),
              Padding(
                padding: _boxPadding,
                child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: ProjectStrings.email),
                    validator: (String value) {
                      bool emailValid =
                          ProjectConstants.emailRegExp.hasMatch(value);
                      if (!emailValid || value.isEmpty) {
                        return ProjectStrings.emailNotValid;
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: _boxPadding,
                child: TextFormField(
                    controller: _phoneController,
                    decoration:
                        InputDecoration(hintText: ProjectStrings.phoneNumber),
                    validator: (String value) {
                      bool phoneValid =
                          ProjectConstants.phoneRegExp.hasMatch(value);
                      if (!phoneValid || value.isEmpty) {
                        return ProjectStrings.phoneNotValid;
                      }
                      return null;
                    }),
              )
            ],
          ),
        ),
      ),
    ]);
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

  Stack researchProgrammesStack() {
    return Stack(
      children: [
        Text(ProjectStrings.researchProgrammes, style: _titleTextStyle),
        Positioned(
            top: contentPadding * 2,
            left: 0,
            right: 0,
            bottom: 0,
            child: StreamBuilder<QuerySnapshot>(
              stream: _researchProgrammes.snapshots(),
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
                return _researchProgrammesList(snapshot);
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
              flex: 5,
              child: Expanded(child: _usersWidget()),
            ),
            Expanded(flex: 5, child: Expanded(child: _groupsWidget()))
          ],
        )
      ],
    );
  }

  Widget _groupsWidget() {
    return new Container(
        margin: _boxPadding,
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
                      child: Text(ProjectStrings.userGroups,
                          style: _subtitleTextStyle))),
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
        margin: _boxPadding,
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
              decoration: new BoxDecoration(
                  color: Colors.grey[200], borderRadius: _borderRadius),
              child: GestureDetector(
                  child: ListTile(
                      title: new Text(document.data()['name']),
                      subtitle: new Text(document.data()['description']),
                      trailing: Icon(Icons.arrow_forward_ios_rounded)),
                  onTap: () => {_navigateToFormStatistics(document.id)}),
            )),
      );
    }).toList());
  }

  ListView formsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.grey[200], borderRadius: _borderRadius),
              child: ListTile(
                  title: new Text(document.data()['name']),
                  subtitle: new Text(document.data()['description']),
                  trailing: dropdownCellMenu(
                      onDelete: () => {_deleteForm(document.id)},
                      onEdit: () => {_editForm(document.id)},
                      onCopy: () => {_copyForm(document.id)})),
            ),
          ),
        );
      }).toList(),
    );
  }

  ListView _researchProgrammesList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.grey[200], borderRadius: _borderRadius),
              child: ListTile(
                  title: new Text(document.data()['name']),
                  trailing: dropdownCellMenu(
                      onDelete: () => {_deleteResearchProgram(document.id)},
                      onEdit: () => {_editResearchProgram(document.id)})),
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
            decoration: new BoxDecoration(
                color: Colors.grey[200], borderRadius: _borderRadius),
            child: GestureDetector(
                child: ListTile(
                  title: new Text(document.data()['name']),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                ),
                onTap: () =>
                    {_navigateToUserStatistics(document.data()['id'])}),
          ),
        ));
      }).toList(),
    );
  }

  Widget dropdownCellMenu(
      {Function onDelete, Function onEdit, Function onCopy}) {
    var items = <String>[];
    if (onEdit != null) {
      items.add(ProjectStrings.edit);
    }
    if (onCopy != null) {
      items.add(ProjectStrings.copy);
    }
    if (onDelete != null) {
      items.add(ProjectStrings.delete);
    }
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
        } else if (newValue == ProjectStrings.delete) {
          onDelete();
        } else {
          onCopy();
        }
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
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

  void _navigateToUserStatistics(String id) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) => UserStatistics(id)));
  }

  void _editForm(String id) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) => EditForm(id)));
  }

  void _editGroup(String id) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) => EditGroup(id)));
  }

  void _editResearchProgram(String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext ctx) => EditResearchProgram(id)));
  }

  void _copyForm(String id) {
    var questionary;
    List newforms = [];
    if (id.isNotEmpty) {
      forms
          .doc(id)
          .get()
          .then((doc) => {questionary = QuestionaryModel(id, doc)})
          .whenComplete(() => {
                if (questionary.questions != null &&
                    questionary.questions.length > 0)
                  {
                    questionary.name = questionary.name +
                        " " +
                        ProjectStrings.copyAddString +
                        UniqueKey().toString(),
                    for (int i = 0; i < questionary.questions.length; i++)
                      newforms.add(questionary.questions[i].itemsList()),
                    forms
                        .add({
                          'name': questionary.name,
                          'isHasCheckList': questionary.isHasCheckList,
                          'checkList': questionary.checkList.itemsList(),
                          'description': questionary.description,
                          'questions': newforms,
                          'groupId': questionary.groupId,
                          'groupName': questionary.groupName
                        })
                        .then((value) => setState(() {}))
                        .catchError((error) => Center(
                            child: Text(error,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red))))
                  }
              });
    }
  }

  void _deleteForm(String id) {
    _alertController.showMessageDialogWithAction(
        context, ProjectStrings.deleteForm, ProjectStrings.deleteFormQuestion,
        () async {
      forms.doc(id).delete().then((value) => print("Form Deleted")).catchError(
          (error) => _alertController.showMessageDialog(
              context, ProjectStrings.deleteFormError, error));
    });
  }

  void _deleteResearchProgram(String id) {
    _alertController.showMessageDialogWithAction(
        context,
        ProjectStrings.deleteResearchProgram,
        ProjectStrings.deleteResearchProgramQuestion, () async {
      _researchProgrammes
          .doc(id)
          .delete()
          .then((value) => print("ResearchProgram Deleted"))
          .catchError((error) => _alertController.showMessageDialog(
              context, ProjectStrings.deleteResearchProgramError, error));
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

  void _saveSettings() async {
    if (_formKey.currentState.validate()) {
      _settings.doc(ProjectConstants.settingsContactCollectionName).update({
        'email': _emailController.text,
        'phone': _phoneController.text
      }).catchError((error) => {
            alertController.showMessageDialog(
                context, ProjectStrings.error, error),
          });
    }
  }
}
