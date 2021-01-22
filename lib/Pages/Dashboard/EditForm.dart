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
  TextStyle _listTitleStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);
  SizedBox _inset = SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dashboard - Gaming Disorder Test Poland',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
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
                  child: Text(
                    "Add new form",
                    style: _titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: _contentPadding,
                  left: _contentPadding,
                  child: BackButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                    top: _contentPadding * 3,
                    left: _contentPadding,
                    right: _contentPadding,
                    bottom: _contentPadding,
                    child: Column(
                      children: [
                        _nameField(),
                        _descriptionField(),
                        _addFieldButton(),
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
          child: new ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _questionary.fields.length,
              itemBuilder: (BuildContext context, int index) {
                return new Padding(
                  padding: const EdgeInsets.all(8.0),
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
                          child: _listElement(_questionary.fields[index]))),
                );
              }));
    } else {
      return Text("No fields have been added yet");
    }
  }

  Widget _listElement(QuestionaryFieldType fieldType) {
    switch (fieldType.type) {
      case QuestionaryFieldAbstract.slider:
        var element = fieldType as SliderFormField;
        return new Column(
          children: [
            Text(element.name, style: _listTitleStyle),
            TextFormField(),
            TextFormField(),
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.likertScale:
        var element = fieldType as LikertScaleFormField;
        return new Column(
          children: [
            Text(element.name),
            TextFormField(),
            TextFormField(),
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.paragraph:
        var element = fieldType as ParagraphFormField;
        return new Column(
          children: [
            Text(element.name, style: _listTitleStyle),
            TextFormField(),
            TextFormField(),
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.multipleChoise:
        var element = fieldType as MultipleChoiseFormField;
        return new Column(
          children: [
            Text(element.name, style: _listTitleStyle),
            TextFormField(),
            TextFormField(),
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
      case QuestionaryFieldAbstract.singleChoise:
        var element = fieldType as SingleChoiseFormField;
        return new Column(
          children: [
            Text(element.name, style: _listTitleStyle),
            TextFormField(),
            TextFormField(),
            _inset,
            _deleteFieldButton(fieldType)
          ],
        );
        break;
    }
    return Text("Empty element");
  }

  Widget _addFieldButton() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: _fieldPadding, bottom: _fieldPadding),
        child: FlatButton(
            onPressed: () {
              print("Add new field");
              _addField();
            },
            color: Colors.deepPurple,
            height: _elementsHeight,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.deepPurple[200])),
            child: Text("Add Field",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white))));
  }

  Widget _deleteFieldButton(QuestionaryFieldType fieldType) {
    return Container(
        width: 200,
        padding: EdgeInsets.only(top: _fieldPadding, bottom: _fieldPadding),
        child: FlatButton(
            onPressed: () {
              print("delete field");
              _deleteField(fieldType);
            },
            color: Colors.red[50],
            height: _elementsHeight,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.red[100])),
            child: Text("Delete",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red[400]))));
  }

  void _addField() {
    setState(() {
      _questionary.fields.add(SliderFormField());
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
