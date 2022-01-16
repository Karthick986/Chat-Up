import 'package:chat_app/chat_detail.dart';
import 'package:chat_app/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Widget navigateFirst;
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser != null) {
    navigateFirst = const ChatUs();
  } else {
    navigateFirst = const MyApp();
  }
  runApp(navigateFirst);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
