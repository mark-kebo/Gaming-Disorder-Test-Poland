import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class EditForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  double _contentPadding = 32;
  double _fieldPadding = 8.0;
  double _elementsHeight = 64.0;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  CollectionReference forms = firestore.collection('forms');
  TextStyle titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  Radius listElementCornerRadius = const Radius.circular(16.0);
  bool _isShowLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                    style: titleTextStyle,
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

  Widget _nameField() {
    return Container(
        margin: EdgeInsets.only(top: _fieldPadding, bottom: _fieldPadding),
        padding: EdgeInsets.all(_fieldPadding),
        height: _elementsHeight,
        decoration: new BoxDecoration(
            color: Colors.grey[200],
            borderRadius: new BorderRadius.only(
                topLeft: listElementCornerRadius,
                topRight: listElementCornerRadius,
                bottomLeft: listElementCornerRadius,
                bottomRight: listElementCornerRadius)),
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
        padding: EdgeInsets.all(_fieldPadding),
        height: _elementsHeight,
        decoration: new BoxDecoration(
            color: Colors.grey[200],
            borderRadius: new BorderRadius.only(
                topLeft: listElementCornerRadius,
                topRight: listElementCornerRadius,
                bottomLeft: listElementCornerRadius,
                bottomRight: listElementCornerRadius)),
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
    setState(() {
      _isShowLoading = true;
    });
    forms
        .add({
          'name': _nameController.text,
          'description': _descriptionController.text
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
