import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:breakout_room_activity/firebase_options.dart';
import 'package:breakout_room_activity/screens/todo_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoList(),
    );
  }
}
