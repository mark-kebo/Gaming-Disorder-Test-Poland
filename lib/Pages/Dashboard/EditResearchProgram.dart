import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Helpers/Alert.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/Questionary.dart';
import 'package:myapp/Models/ResearchProgram.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class EditResearchProgram extends StatefulWidget {
  String id;

  EditResearchProgram(String id) {
    this.id = id;
  }

  @override
  State<StatefulWidget> createState() => _EditResearchProgramState(id);
}

class _EditResearchProgramState extends State<EditResearchProgram> {
  String id;
  double _contentPadding = 32;
  double _fieldPadding = 8.0;
  double _elementsHeight = 64.0;
  Color _elementBackgroundColor = Colors.grey[200];
  final _nameController = TextEditingController();
  CollectionReference _formsCollection =
      firestore.collection(ProjectConstants.formsCollectionName);
  CollectionReference _researchProgrammesCollection =
      firestore.collection(ProjectConstants.researchProgrammesCollectionName);
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  Radius _listElementCornerRadius = const Radius.circular(16.0);
  bool _isShowLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AlertController alertController = AlertController();
  ResearchProgramModel _researchProgramModel = ResearchProgramModel(null);
  List<QuestionaryModel> _allForms = [];

  _EditResearchProgramState(String id) {
    this.id = id;
    _prepareViewData();
  }

  void _prepareViewData() {
    if (id.isNotEmpty) {
      _researchProgrammesCollection.doc(id).get().then((doc) => {
            setState(() {
              _researchProgramModel = ResearchProgramModel(doc);
              _nameController.text = _researchProgramModel.name;
            })
          });
    }
    _formsCollection.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            _allForms.add(QuestionaryModel(doc.id, doc));
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
              ProjectStrings.researchProgram,
              style: _titleTextStyle,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.deepPurple,
                onPressed: () async {
                  print("Add new field");
                  _addNewField();
                },
                child: Text(ProjectStrings.addNewField),
              ),
            ],
            leading: BackButton(
              color: Colors.deepPurple,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          floatingActionButton: _isShowLoading
              ? CircularProgressIndicator()
              : FloatingActionButton(
                  child: Icon(Icons.done),
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _updateAction();
                    }
                  },
                ),
          body: Form(
            key: _formKey,
            child: Stack(
              children: [
                Positioned(
                    top: _contentPadding,
                    left: _contentPadding,
                    right: _contentPadding,
                    bottom: _contentPadding,
                    child: Column(
                      children: [
                        _nameField(),
                        Text(
                          ProjectStrings.formsList,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 24,
                              color: Colors.deepPurple),
                        ),
                        _fieldsList()
                      ],
                    )),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _fieldsList() {
    if (_researchProgramModel.forms != null &&
        _researchProgramModel.forms.length > 0) {
      return Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _researchProgramModel.forms.length,
              itemBuilder: (BuildContext context, int index) {
                return new Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: new Container(
                      decoration: new BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: new BorderRadius.only(
                              topLeft: _listElementCornerRadius,
                              topRight: _listElementCornerRadius,
                              bottomLeft: _listElementCornerRadius,
                              bottomRight: _listElementCornerRadius)),
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _listElement(
                              _researchProgramModel.forms[index], index))),
                );
              }));
    } else {
      return Text(ProjectStrings.noFields, style: TextStyle(color: Colors.red));
    }
  }

  Widget _listElement(ResearchProgramForm researchProgramForm, int index) {
    return new Column(
      children: [
        _fieldFormsWidget(researchProgramForm),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () =>
                        _selectDate(context, researchProgramForm, true),
                    child: Text(
                        ProjectStrings.dateFrom +
                            researchProgramForm.dateTimeFromString(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                  ))),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => _selectDate(context, researchProgramForm, false),
              child: Text(
                  ProjectStrings.dateTo +
                      researchProgramForm.dateTimeToString(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),
            ),
          ))
        ]),
        _deleteFieldButton(researchProgramForm),
      ],
    );
  }

  Widget _fieldFormsWidget(ResearchProgramForm researchProgramForm) {
    return Row(children: [
      Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(ProjectStrings.form, style: TextStyle(fontSize: 16))),
      Expanded(
          child: DropdownButton<String>(
        iconSize: 0.0,
        iconDisabledColor: Colors.grey[200],
        iconEnabledColor: Colors.grey[200],
        style: TextStyle(color: Colors.deepPurple, fontSize: 16),
        hint: Text(researchProgramForm.formName ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16)),
        underline: Container(
          height: 1,
          color: Colors.grey[300],
        ),
        onChanged: (String newValue) {
          setState(() {
            researchProgramForm.formId = newValue;
            researchProgramForm.formName = _allForms
                .firstWhere(
                    (element) => element.id == researchProgramForm.formId)
                .name;
          });
        },
        items:
            _allForms.map<DropdownMenuItem<String>>((QuestionaryModel value) {
          return DropdownMenuItem<String>(
            value: value.id,
            child: Text(value.name),
          );
        }).toList(),
      ))
    ]);
  }

  Future<void> _selectDate(BuildContext context,
      ResearchProgramForm researchProgramForm, bool isFrom) async {
    DateTime selectedDate = (isFrom
            ? researchProgramForm.dateTimeFrom
            : researchProgramForm.dateTimeTo) ??
        DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000));
    if (picked != null && picked != selectedDate) {
      print("new date: $picked");
      setState(() {
        if (isFrom) {
          researchProgramForm.dateTimeFrom = picked;
        } else {
          researchProgramForm.dateTimeTo = picked;
        }
      });
    }
  }

  Widget _deleteFieldButton(ResearchProgramForm researchProgramForm) {
    return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              print("delete field");
              _deleteField(researchProgramForm);
            }));
  }

  Widget _nameField() {
    return Container(
        margin: EdgeInsets.only(top: _fieldPadding, bottom: _fieldPadding),
        padding: EdgeInsets.only(
            top: _fieldPadding,
            bottom: _fieldPadding,
            left: _fieldPadding * 2,
            right: _fieldPadding * 2),
        height: _elementsHeight,
        decoration: new BoxDecoration(
            color: _elementBackgroundColor,
            borderRadius: new BorderRadius.only(
                topLeft: _listElementCornerRadius,
                topRight: _listElementCornerRadius,
                bottomLeft: _listElementCornerRadius,
                bottomRight: _listElementCornerRadius)),
        child: TextFormField(
          controller: _nameController,
          validator: (String value) {
            if (value.isEmpty) {
              return ProjectStrings.nameRequired;
            }
            return null;
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: ProjectStrings.researchProgramName),
        ));
  }

  void _deleteField(ResearchProgramForm researchProgramForm) {
    setState(() {
      _researchProgramModel.forms.remove(researchProgramForm);
    });
  }

  void _addNewField() {
    setState(() {
      _researchProgramModel.forms.add(ResearchProgramForm(null));
    });
  }

  void _updateAction() async {
    if (_researchProgramModel.forms != null &&
        _researchProgramModel.forms.length > 0) {
      _researchProgramModel.name = _nameController.text ?? "";
      setState(() {
        _isShowLoading = true;
      });
      List forms = [];
      for (int i = 0; i < _researchProgramModel.forms.length; i++)
        forms.add(_researchProgramModel.forms[i].itemsList());
      this.id.isEmpty
          ? _researchProgrammesCollection
              .add({
                'name': _researchProgramModel.name,
                'id': _researchProgramModel.id,
                'forms': forms
              })
              .then((value) => setState(() {
                    Navigator.pop(context);
                    _isShowLoading = false;
                  }))
              .catchError((error) => Center(
                  child: Text(error,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red))))
          : _formsCollection
              .doc(id)
              .update({
                'name': _researchProgramModel.name,
                'id': _researchProgramModel.id,
                'forms': forms
              })
              .then((value) => setState(() {
                    Navigator.pop(context);
                    _isShowLoading = false;
                  }))
              .catchError((error) => Center(
                  child: Text(error,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red))));
    }
  }
}
