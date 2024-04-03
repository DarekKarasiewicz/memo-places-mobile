import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.amber,
            title: const Text("Profile")
            ),
      body: Center(
            child: Text("Profile", style: TextStyle(fontSize: 60),)),
      ),
    );
  }
}