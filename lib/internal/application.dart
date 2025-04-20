import 'package:flutter/material.dart';
import 'package:test_flut/presentation/login.dart';
import 'package:test_flut/presentation/registration.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color.fromARGB(0, 255, 255, 255),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}