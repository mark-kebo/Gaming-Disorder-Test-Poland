import 'package:flutter/material.dart';
import 'package:myapp/Pages/Login/Login.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // TODO:- Check for errors
        if (snapshot.hasError) {
          return Center(
            child: Text('Error', style: Theme
                .of(context)
                .textTheme
                .headline4)
          );
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        // TODO:- Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: Text('Loading...', style: Theme
              .of(context)
              .textTheme
              .headline4)
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard - Gaming Disorder Test Poland',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}