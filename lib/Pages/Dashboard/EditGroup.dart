import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class EditGroup extends StatefulWidget {
  String id;

  EditGroup(String id) {
    this.id = id;
  }

  @override
  State<StatefulWidget> createState() => _EditGroupState(id);
}

class _EditGroupState extends State<EditGroup> {
  String id;

  _EditGroupState(String id) {
    this.id = id;
    // _prepareViewData();
  }

  double _contentPadding = 32;
  double _fieldPadding = 8.0;
  double _elementsHeight = 64.0;
  Color _elementBackgroundColor = Colors.grey[200];
  final _nameController = TextEditingController();
  CollectionReference _usersCollection = firestore.collection('users');
  TextStyle _titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 32, color: Colors.deepPurple);
  Radius _listElementCornerRadius = const Radius.circular(16.0);
  bool _isShowLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BorderRadius _borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.0),
      topRight: Radius.circular(16.0),
      bottomLeft: Radius.circular(16.0),
      bottomRight: Radius.circular(16.0));

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
              "Group",
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
          floatingActionButton: _isShowLoading
              ? CircularProgressIndicator()
              : FloatingActionButton(
                  child: Icon(Icons.done),
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      // _updateFormAction();
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
                          "Users",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 24,
                              color: Colors.deepPurple),
                        ),
                        _usersListView()
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

  Widget _usersListView() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: _usersCollection.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Something went wrong',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return _usersList(snapshot);
      },
    ));
  }

  ListView _usersList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
            child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Container(
            height: 46.0,
            decoration: new BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepPurple[100]))),
            child: ListTile(
                title: new Row(children: [
              Expanded(
                  flex: 9,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(document.data()['name']))),
              Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Checkbox(
                        value: true, /////////
                        onChanged: (newValue) {
                          setState(() {}); ///////
                        },
                      )))
            ])),
          ),
        ));
      }).toList(),
    );
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

  // void _updateFormAction() async {
  //   if (_questionary.fields != null && _questionary.fields.length > 0) {
  //     _questionary.name = _nameController.text;
  //     _questionary.description = _descriptionController.text;
  //     setState(() {
  //       _isShowLoading = true;
  //     });
  //     List forms = [];
  //     for (int i = 0; i < _questionary.fields.length; i++)
  //       forms.add(_questionary.fields[i].itemsList());
  //     this.id.isEmpty
  //         ? _formsCollection
  //             .add({
  //               'name': _questionary.name,
  //               'description': _questionary.description,
  //               'forms': forms
  //             })
  //             .then((value) => setState(() {
  //                   Navigator.pop(context);
  //                   _isShowLoading = false;
  //                 }))
  //             .catchError((error) => Center(
  //                 child: Text(error,
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.bold, color: Colors.red))))
  //         : _formsCollection
  //             .doc(id)
  //             .update({
  //               'name': _questionary.name,
  //               'description': _questionary.description,
  //               'forms': forms
  //             })
  //             .then((value) => setState(() {
  //                   Navigator.pop(context);
  //                   _isShowLoading = false;
  //                 }))
  //             .catchError((error) => Center(
  //                 child: Text(error,
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.bold, color: Colors.red))));
  //   }
  // }
}
