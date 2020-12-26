import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoginScreen(),
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Center(
        child: SizedBox(
          width: 450,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  double _formPadding = 24.0;
  double _fieldPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    return Form (
      child: Padding(
        padding: EdgeInsets.all(_formPadding),
        child: Column (
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome', style: Theme
              .of(context)
              .textTheme
              .headline4),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                controller: _firstNameTextController,
                decoration: InputDecoration(hintText: 'Email'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                controller: _lastNameTextController,
                decoration: InputDecoration(hintText: 'Password'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: _formPadding),
              child: FlatButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                onPressed: _handleLoginButton,
                child: Padding(
                  padding: EdgeInsets.only(left: _formPadding, right: _formPadding, top: _fieldPadding, bottom: _fieldPadding),
                  child: Text('Sign in', 
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ), 
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginButton() {

  }
}