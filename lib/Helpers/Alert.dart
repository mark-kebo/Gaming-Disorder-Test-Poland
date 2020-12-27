import 'package:flutter/material.dart';

class AlertController {

  void showMessageDialog(BuildContext context, String titleText, String bodyText) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () { 
        Navigator.of(context, rootNavigator: true).pop(); 
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(titleText),
      content: Text(bodyText),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}