import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Models/Questionary.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class EditForm extends StatefulWidget {
  String id;

  EditForm(String id) {
    this.id = id;
  }

  @override
  State<StatefulWidget> createState() => _EditFormState(id);
}

class _EditFormState extends State<EditForm> {
  String id;

  _EditFormState(String id) {
    this.id = id;
    _prepareViewData();
  }

  double _contentPadding = 32;
  double _fieldPadding = 8.0;
  double _elementsHeight = 64.0;
  Color _elementBackgroundColor = Colors.grey[200];
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  CollectionReference _formsCollection = firestore.collection(ProjectConstants.formsCollectionName);
  CollectionReference _userGroups = firestore.collection(ProjectConstants.groupsCollectionName);
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  Radius _listElementCornerRadius = const Radius.circular(16.0);
  bool _isShowLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  QuestionaryModel _questionary = QuestionaryModel(null, null);
  TextStyle _listTitleStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple);
  SizedBox _inset = SizedBox(height: 16, width: 16);
  Map<String, String> groupItems = Map<String, String>();

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
              ProjectStrings.form,
              style: _titleTextStyle,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.deepPurple,
                onPressed: () async {
                  print("Add new field");
                  _showFieldTypeDialog();
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
                      _updateFormAction();
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
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        _nameField(),
                        _descriptionField(),
                        _groupField(),
                        _fieldsList()
                      ],
                    ))),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _prepareViewData() {
    _userGroups.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            setState(() {
              groupItems[doc.id] = doc["name"];
            });
          })
        });
    if (id.isNotEmpty) {
      _formsCollection.doc(id).get().then((doc) => {
            setState(() {
              _questionary = QuestionaryModel(id, doc);           
               _nameController.text = _questionary.name;
            _descriptionController.text = _questionary.description;
            })
          });
    }
  }

  Widget _fieldsList() {
    if (_questionary.questions != null && _questionary.questions.length > 0) {
      return ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questionary.questions.length,
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
                      child:
                          _listElement(_questionary.questions[index], index))),
            );
          });
    } else {
      return Text(ProjectStrings.noFields,
          style: TextStyle(color: Colors.red));
    }
  }

  Widget _listElement(QuestionaryFieldType fieldType, int index) {
    switch (fieldType.type) {
      case QuestionaryFieldAbstract.slider:
        var element = fieldType as SliderFormField;
        return _sliderField(element, index);
        break;
      case QuestionaryFieldAbstract.likertScale:
        var element = fieldType as LikertScaleFormField;
        return _likertScaleField(element, index);
        break;
      case QuestionaryFieldAbstract.paragraph:
        var element = fieldType as ParagraphFormField;
        return _paragraphField(element, index);
        break;
      case QuestionaryFieldAbstract.multipleChoise:
        var element = fieldType as MultipleChoiseFormField;
        return _multipleChoiseField(element, index);
        break;
      case QuestionaryFieldAbstract.singleChoise:
        var element = fieldType as SingleChoiseFormField;
        return _singleChoiseField(element, index);
        break;
    }
    return Text(ProjectStrings.emptyElement);
  }

  Widget _sliderField(SliderFormField fieldType, int index) {
    return new Column(
      children: [
        _questionTextField(fieldType, index),
        _inset,
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextFormField(
                  onChanged: (text) {
                    setState(() {});
                  },
                  controller: fieldType.minValueController,
                  decoration:
                      InputDecoration(hintText: ProjectStrings.minValueDescription),
                ),
              )),
          Expanded(
              flex: 5,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextFormField(
                      onChanged: (text) {
                        setState(() {});
                      },
                      controller: fieldType.maxValueController,
                      decoration: InputDecoration(
                          hintText: ProjectStrings.maxValueDescription),
                    ),
                  )))
        ]),
        _inset,
        _deleteFieldButton(fieldType),
        _inset,
        _keyFields(fieldType),
      ],
    );
  }

  Widget _likertScaleField(LikertScaleFormField fieldType, int index) {
    return new Column(
      children: [
        _questionTextField(fieldType, index),
        _inset,
        for (var item in _optionsLikertScaleList(fieldType)) item,
        _inset,
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _addFieldElementdButton(fieldType),
          _deleteFieldButton(fieldType)
        ]),
        _inset,
        _keyFields(fieldType),
      ],
    );
  }

  Widget _paragraphField(ParagraphFormField fieldType, int index) {
    return new Column(
      children: [
        _questionTextField(fieldType, index),
        _inset,
        _deleteFieldButton(fieldType),
        _inset,
        _keyFields(fieldType),
      ],
    );
  }

  Widget _multipleChoiseField(MultipleChoiseFormField fieldType, int index) {
    return new Column(
      children: [
        _questionTextField(fieldType, index),
        _inset,
        for (var item in _optionsMultipleChoiseList(fieldType)) item,
        _inset,
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _addFieldElementdButton(fieldType),
          _deleteFieldButton(fieldType)
        ]),
        _inset,
        _keyFields(fieldType),
      ],
    );
  }

  Widget _singleChoiseField(SingleChoiseFormField fieldType, int index) {
    return new Column(
      children: [
        _questionTextField(fieldType, index),
        _inset,
        for (var item in _optionsSingleChoiseList(fieldType)) item,
        _inset,
        Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
                width: 270,
                child: CheckboxListTile(
                  title: Text(ProjectStrings.isKeyQuestion),
                  onChanged: (bool val) {
                    setState(() {
                      fieldType.isKeyQuestion = !fieldType.isKeyQuestion;
                    });
                    print(fieldType.isKeyQuestion);
                  },
                  value: fieldType.isKeyQuestion,
                ))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _addFieldElementdButton(fieldType),
          _deleteFieldButton(fieldType)
        ]),
        _inset,
        fieldType.isKeyQuestion ? _inset : _keyFields(fieldType),
      ],
    );
  }

  List<Widget> _optionsSingleChoiseList(SingleChoiseFormField fieldType) {
    if (fieldType.optionsControllers != null &&
        fieldType.optionsControllers.length > 0) {
      return fieldType.optionsControllers
          .asMap()
          .map((index, field) => MapEntry(
              index,
              SizedBox(
                height: _elementsHeight,
                child: _optionTextField(fieldType, index),
              )))
          .values
          .toList();
    } else {
      return [Text(ProjectStrings.noOptions)];
    }
  }

  List<Widget> _optionsMultipleChoiseList(MultipleChoiseFormField fieldType) {
    if (fieldType.optionsControllers != null &&
        fieldType.optionsControllers.length > 0) {
      return fieldType.optionsControllers
          .asMap()
          .map((index, field) => MapEntry(
              index,
              SizedBox(
                height: _elementsHeight,
                child: _optionTextField(fieldType, index),
              )))
          .values
          .toList();
    } else {
      return [Text(ProjectStrings.noOptions)];
    }
  }

  List<Widget> _optionsLikertScaleList(LikertScaleFormField fieldType) {
    if (fieldType.optionsControllers != null &&
        fieldType.optionsControllers.length > 0) {
      return fieldType.optionsControllers
          .asMap()
          .map((index, field) => MapEntry(
              index,
              SizedBox(
                height: _elementsHeight,
                child: _optionTextField(fieldType, index),
              )))
          .values
          .toList();
    } else {
      return [Text(ProjectStrings.noOptions)];
    }
  }

  Widget _questionTextField(QuestionaryFieldType fieldType, int index) {
    return Container(
        padding: EdgeInsets.only(
            top: _fieldPadding * 2,
            bottom: _fieldPadding * 2,
            left: _fieldPadding * 2,
            right: _fieldPadding * 2),
        decoration: new BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: new BorderRadius.only(
                topLeft: _listElementCornerRadius,
                topRight: _listElementCornerRadius,
                bottomLeft: _listElementCornerRadius,
                bottomRight: _listElementCornerRadius)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text((index + 1).toString() + ". ", style: _listTitleStyle),
          Expanded(
            flex: 8,
            child: TextFormField(
              onChanged: (text) {
                setState(() {});
              },
              controller: fieldType.questionController,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: ProjectStrings.question),
            ),
          ),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(fieldType.name, style: _listTitleStyle))),
          _inset,
          fieldType.icon
        ]));
  }

  Widget _optionTextField(QuestionaryFieldType fieldType, int index) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
        flex: 9,
        child: TextFormField(
          onChanged: (text) {
            setState(() {});
          },
          controller: fieldType.optionsControllers[index],
          decoration:
              InputDecoration(hintText: ProjectStrings.option + (index + 1).toString()),
        ),
      ),
      Expanded(
          flex: 1,
          child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(
                    Icons.delete_outlined,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    print("delete option field");
                    _deleteFieldOption(fieldType, index);
                  })))
    ]);
  }

  Widget _deleteFieldButton(QuestionaryFieldType fieldType) {
    return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              print("delete field");
              _deleteField(fieldType);
            }));
  }

  Widget _addFieldElementdButton(QuestionaryFieldType fieldType) {
    return Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              print("add field element");
              _addFieldOption(fieldType);
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
          onChanged: (text) {
            setState(() {});
          },
          validator: (String value) {
            if (value.isEmpty) {
              return ProjectStrings.nameRequired;
            }
            return null;
          },
          decoration: InputDecoration(
              border: InputBorder.none, hintText: ProjectStrings.formName),
        ));
  }

  Widget _descriptionField() {
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
          controller: _descriptionController,
          onChanged: (text) {
            setState(() {});
          },
          validator: (String value) {
            if (value.isEmpty) {
              return ProjectStrings.descriptionRequired;
            }
            return null;
          },
          decoration: InputDecoration(
              border: InputBorder.none, hintText: ProjectStrings.formDescription),
        ));
  }

  Widget _groupField() {
    return Container(
        padding: EdgeInsets.only(
            top: _fieldPadding,
            bottom: _fieldPadding,
            left: _fieldPadding * 2,
            right: _fieldPadding * 2),
        child: Align(
            alignment: Alignment.centerRight,
            child: Row(children: [
              Text(ProjectStrings.selectedGroup, style: TextStyle(fontSize: 16)),
              Expanded(
                  child: DropdownButton<String>(
                iconSize: 0.0,
                iconDisabledColor: Colors.white,
                iconEnabledColor: Colors.white,
                style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                hint: Text(_questionary.groupName,
                    style: TextStyle(fontSize: 16)),
                underline: Container(
                  height: 2,
                  color: Colors.grey[200],
                ),
                onChanged: (String newValue) {
                  setState(() {
                    _questionary.groupId = newValue;
                    _questionary.groupName = groupItems[newValue];
                  });
                },
                items: groupItems
                    .map<String, DropdownMenuItem<String>>(
                        (String key, String value) {
                      return MapEntry(
                          key,
                          DropdownMenuItem<String>(
                            value: key,
                            child: Text(value),
                          ));
                    })
                    .values
                    .toList(),
              ))
            ])));
  }

  void _addField(QuestionaryFieldType field) {
    setState(() {
      _questionary.questions.add(field);
    });
  }

  void _deleteField(QuestionaryFieldType fieldType) {
    setState(() {
      _questionary.questions.remove(fieldType);
    });
  }

  void _addFieldOption(QuestionaryFieldType fieldType) {
    setState(() {
      switch (fieldType.type) {
        case QuestionaryFieldAbstract.likertScale:
          var element = fieldType as LikertScaleFormField;
          element.optionsControllers.add(TextEditingController());
          break;
        case QuestionaryFieldAbstract.multipleChoise:
          var element = fieldType as MultipleChoiseFormField;
          element.optionsControllers.add(TextEditingController());
          break;
        case QuestionaryFieldAbstract.singleChoise:
          var element = fieldType as SingleChoiseFormField;
          element.optionsControllers.add(TextEditingController());
          break;
        default:
          break;
      }
    });
  }

  void _deleteFieldOption(QuestionaryFieldType fieldType, int index) {
    setState(() {
      switch (fieldType.type) {
        case QuestionaryFieldAbstract.likertScale:
          var element = fieldType as LikertScaleFormField;
          element.optionsControllers.remove(element.optionsControllers[index]);
          break;
        case QuestionaryFieldAbstract.multipleChoise:
          var element = fieldType as MultipleChoiseFormField;
          element.optionsControllers.remove(element.optionsControllers[index]);
          break;
        case QuestionaryFieldAbstract.singleChoise:
          var element = fieldType as SingleChoiseFormField;
          element.optionsControllers.remove(element.optionsControllers[index]);
          break;
        default:
          break;
      }
    });
  }

  void _updateFormAction() async {
    if (_questionary.questions != null && _questionary.questions.length > 0) {
      _questionary.name = _nameController.text;
      _questionary.description = _descriptionController.text;
      setState(() {
        _isShowLoading = true;
      });
      List forms = [];
      for (int i = 0; i < _questionary.questions.length; i++)
        forms.add(_questionary.questions[i].itemsList());
      this.id.isEmpty
          ? _formsCollection
              .add({
                'name': _questionary.name,
                'description': _questionary.description,
                'questions': forms,
                'groupId': _questionary.groupId,
                'groupName': _questionary.groupName
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
                'name': _questionary.name,
                'description': _questionary.description,
                'questions': forms,
                'groupId': _questionary.groupId,
                'groupName': _questionary.groupName
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

  Widget _keyFields(QuestionaryFieldType question) {
    var filtredQuestions = _questionary.questions
        .where((element) => element.key == "singleChoise")
        .where((element) => (element as SingleChoiseFormField).isKeyQuestion)
        .where((element) => element.questionController.text.isNotEmpty)
        .toList();
    List<String> options = [];
    var selectedQuestion = filtredQuestions.firstWhere(
        (element) => question.keyQuestion == element.questionController.text,
        orElse: () => null);
    print(selectedQuestion);
    if (selectedQuestion != null) {
      var optionsControllers = selectedQuestion.optionsControllers;
      if (optionsControllers.isNotEmpty && optionsControllers != null) {
        options = optionsControllers
            .where((element) => element.text.isNotEmpty)
            .map((e) => e.text)
            .toList();
      }
    }
    print(question.keyQuestion);
    return filtredQuestions.isEmpty
        ? _inset
        : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Expanded(
                flex: 5,
                child: Row(children: [
                  Text(ProjectStrings.selectKeyQuestion,
                      style: TextStyle(fontSize: 16)),
                  Expanded(
                      child: DropdownButton<String>(
                    iconSize: 0.0,
                    iconDisabledColor: Colors.grey[200],
                    iconEnabledColor: Colors.grey[200],
                    style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                    hint: Text(question.keyQuestion ?? '',
                        style: TextStyle(fontSize: 16)),
                    underline: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        question.keyQuestion = newValue;
                      });
                    },
                    items: filtredQuestions.map<DropdownMenuItem<String>>(
                        (QuestionaryFieldType value) {
                      return DropdownMenuItem<String>(
                        value: value.questionController.text,
                        child: Text(
                            value.name + " - " + value.questionController.text),
                      );
                    }).toList(),
                  ))
                ])),
            options.isEmpty
                ? _inset
                : Expanded(
                    flex: 5,
                    child: Row(children: [
                      Text(ProjectStrings.selectKeyAnswer,
                          style: TextStyle(fontSize: 16)),
                      Expanded(
                          child: DropdownButton<String>(
                        iconSize: 0.0,
                        iconDisabledColor: Colors.grey[200],
                        iconEnabledColor: Colors.grey[200],
                        style:
                            TextStyle(color: Colors.deepPurple, fontSize: 16),
                        hint: Text(question.keyQuestionOption ?? '',
                            style: TextStyle(fontSize: 16)),
                        underline: Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            question.keyQuestionOption = newValue;
                          });
                        },
                        items: options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ))
                    ]))
          ]);
  }

  void _showFieldTypeDialog() {
    String selectedRadio = "";
    List<QuestionaryFieldType> questionaryFields = [
      SingleChoiseFormField(null),
      SliderFormField(null),
      MultipleChoiseFormField(null),
      ParagraphFormField(null),
      LikertScaleFormField(null)
    ];

    Widget okButton = FlatButton(
      child: Text(ProjectStrings.ok),
      onPressed: () {
        for (var item in questionaryFields) {
          if (item.key == selectedRadio) {
            _addField(item);
            Navigator.of(context, rootNavigator: true).pop();
            break;
          }
        }
      },
    );
    Widget cancelButton = FlatButton(
      child: Text(ProjectStrings.cancel),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(ProjectStrings.selectFieldType,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: questionaryFields
                        .map((e) => RadioListTile<String>(
                              value: e.key,
                              title: Text(e.name),
                              groupValue: selectedRadio,
                              onChanged: (String value) {
                                setState(() => selectedRadio = value);
                              },
                            ))
                        .toList());
              },
            ),
            actions: [okButton, cancelButton],
          );
        });
  }
}
