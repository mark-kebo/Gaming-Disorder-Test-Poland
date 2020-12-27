import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  double _formPadding = 24.0;
  double _fieldPadding = 8.0;

  bool _success;
  String _userEmail;

  @override
  Widget build(BuildContext context) {
    return Form (
      key: _formKey,
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
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Email'),
                validator: (String value) {
                  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                  if (!emailValid || value.isEmpty) {
                    return 'A valid email is required';
                  }
                  return null;
                }
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Password'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'A password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                obscureText: true
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: _formPadding),
              child: FlatButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _signInWithEmailAndPassword();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(left: _formPadding, right: _formPadding, top: _fieldPadding, bottom: _fieldPadding),
                  child: Text('Sign in', 
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ), 
            ),
            Container(
              alignment: Alignment.center,
              child: Padding(
              padding: EdgeInsets.only(top: _success == null ? 0 : _formPadding),
              child: Text(
                  _success == null
                      ? ''
                      : (_success
                      ? 'Successfully signed in ' + _userEmail
                      : 'Sign in failed'),
                  style: TextStyle(color: Colors.red[300]),
                )
              )
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

void _signInWithEmailAndPassword() async {
  print("Sign in");
    final User user = (await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )).user;
  
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
    } else {
      setState(() {
        _success = false;
      });
    }
      print("Signed in with: ");
      print(_success);
  }
}