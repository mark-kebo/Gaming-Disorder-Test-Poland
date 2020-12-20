import 'package:flutter/material.dart';

void main() => runApp(SignUpApp());

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => SignUpScreen(),
      },
    );
  }
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _usernameTextController = TextEditingController();

  double _formProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _formProgress),
          Text('Sign in', style: Theme
              .of(context)
              .textTheme
              .headline4),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _firstNameTextController,
              decoration: InputDecoration(hintText: 'Email'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _lastNameTextController,
              decoration: InputDecoration(hintText: 'Password'),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                return states.contains(MaterialState.disabled) ? null : Colors.white;
              }),
              backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                return states.contains(MaterialState.disabled) ? null : Colors.blue;
              }),
            ),
            onPressed: null,
            child: Text('Sign in'),
          ),
        ],
      ),
    );
  }
}