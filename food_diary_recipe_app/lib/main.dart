import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_diary_recipe_app/AuthPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Diary',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthPage(),
    );
  }
}