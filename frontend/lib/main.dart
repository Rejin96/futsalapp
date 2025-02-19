import 'package:flutter/material.dart';
import 'package:playerconnect/src/pages/start_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Kick Connect",
        home: StartingPage());
  }
}
