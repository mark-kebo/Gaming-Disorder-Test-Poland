import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/Helpers/Alert.dart';
import 'package:myapp/Helpers/Constants.dart';
import 'package:myapp/Helpers/Strings.dart';
import 'package:myapp/Pages/Dashboard/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ProjectStrings.projectName,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LoginScreen(),
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

  final AlertController alertController = AlertController();

  double _formPadding = 24.0;
  double _fieldPadding = 8.0;
  bool _isShowLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(_formPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ProjectStrings.projectName,
                style: Theme.of(context).textTheme.headline4),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: ProjectStrings.email),
                  validator: (String value) {
                    bool emailValid =
                        ProjectConstants.emailRegExp.hasMatch(value);
                    if (!emailValid || value.isEmpty) {
                      return ProjectStrings.emailNotValid;
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                  controller: _passwordController,
                  decoration:
                      InputDecoration(hintText: ProjectStrings.password),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return ProjectStrings.emptyPassword;
                    }
                    if (value.length < 6) {
                      return ProjectStrings.passwordNotValid;
                    }
                    return null;
                  },
                  obscureText: true),
            ),
            Padding(
              padding: EdgeInsets.only(top: _formPadding),
              child: _isShowLoading
                  ? CircularProgressIndicator()
                  : FlatButton(
                      color: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _signInAction();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: _formPadding,
                            right: _formPadding,
                            top: _fieldPadding,
                            bottom: _fieldPadding),
                        child: Text(ProjectStrings.login,
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
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

  void _signInAction() async {
    setState(() {
      _isShowLoading = true;
    });
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(ProjectConstants.prefsEmail, _emailController.text);
      prefs.setString(ProjectConstants.prefsPassword, _passwordController.text);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext ctx) => Dashboard()));
      setState(() {
        _isShowLoading = false;
      });
    } catch (error) {
      alertController.showMessageDialog(
          context, ProjectStrings.error, error.message);
      setState(() {
        _isShowLoading = false;
      });
    }
  }
}
