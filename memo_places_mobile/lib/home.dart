import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.lightBlue,
            title: const Text("Home")
            ),
      body: Center(
            child: Text("Home", style: TextStyle(fontSize: 60),)),
      ),
    );
  }
}