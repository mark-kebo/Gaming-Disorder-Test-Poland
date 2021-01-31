import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Models/Questionary.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class EditForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  double _contentPadding = 32;
  double _fieldPadding = 8.0;
  double _elementsHeight = 64.0;
  Color _elementBackgroundColor = Colors.grey[200];
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  CollectionReference _formsCollection = firestore.collection('forms');
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  Radius _listElementCornerRadius = const Radius.circular(16.0);
  bool _isShowLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<FormField> fields = <FormField>[];
  Questionary _questionary = Questionary();
  TextStyle _listTitleStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple);
  SizedBox _inset = SizedBox(height: 16);

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
              "Add new form",
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
                child: Text('Add new field'),
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
                      _createFormAction();
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
                        _descriptionField(),
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
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _fieldsList() {
    if (_questionary.fields != null && _questionary.fields.length > 0) {
      return Expanded(
          child: ListView.builder(
              itemCount: _questionary.fields.length,
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
                              _listElement(_questionary.fields[index], index))),
                );
              }));
    } else {
      return Text("No fields have been added yet");
    }
  }

  Widget _listElement(QuestionaryFieldType fieldType, int index) {
    switch (fieldType.type) {
      case QuestionaryFieldAbstract.slider:
        var element = fieldType as SliderFormField;
        return new Column(
          children: [
            _questionTextField(element, index),
            _inset,
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Minimum value description'),
                    ),
                  )),
              Expanded(
                  flex: 5,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Maximum value description'),
                        ),
                      )))
            ]),
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.likertScale:
        var element = fieldType as LikertScaleFormField;
        return new Column(
          children: [
            _questionTextField(element, index),
            _inset,
            // TextFormField(),//list with textfields
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.paragraph:
        var element = fieldType as ParagraphFormField;
        return new Column(
          children: [
            _questionTextField(element, index),
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.multipleChoise:
        var element = fieldType as MultipleChoiseFormField;
        return new Column(
          children: [
            _questionTextField(element, index),
            _inset,
            TextFormField(), //list
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.singleChoise:
        var element = fieldType as SingleChoiseFormField;
        return new Column(
          children: [
            _questionTextField(element, index),
            _inset,
            TextFormField(), //list
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
    }
    return Text("Empty element");
  }

  void _showFieldTypeDialog() {
    String selectedRadio = "";
    List<QuestionaryFieldType> questionaryFields = [
      SingleChoiseFormField(),
      SliderFormField(),
      MultipleChoiseFormField(),
      ParagraphFormField(),
      LikertScaleFormField()
    ];

    Widget okButton = FlatButton(
      child: Text("OK"),
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
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Please select the type of added field",
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
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Question'),
            ),
          ),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(fieldType.name, style: _listTitleStyle)))
        ]));
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

  void _addField(QuestionaryFieldType field) {
    setState(() {
      _questionary.fields.add(field);
    });
  }

  void _deleteField(QuestionaryFieldType fieldType) {
    setState(() {
      _questionary.fields.remove(fieldType);
    });
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
              return 'A name is required';
            }
            return null;
          },
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Enter a form name'),
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
          validator: (String value) {
            if (value.isEmpty) {
              return 'A description is required';
            }
            return null;
          },
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Enter a form description'),
        ));
  }

  void _createFormAction() async {
    _questionary.name = _nameController.text;
    _questionary.description = _descriptionController.text;
    setState(() {
      _isShowLoading = true;
    });
    _formsCollection
        .add({
          'name': _questionary.name,
          'description': _questionary.description
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
