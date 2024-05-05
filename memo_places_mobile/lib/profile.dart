import 'package:flutter/material.dart';
import 'package:memo_places_mobile/Objects/buttonData.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileButton.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileInfoBox.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/profile_my_places.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<String?> _futureAccess = _loadCounter("access");
  List<ButtonData> buttonsData = [];

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _initializeButtonsData();
  }

  void _initializeButtonsData() {
    buttonsData = [
      ButtonData(text: "Edit profile", onTap: onTap),
      ButtonData(text: "My Places", onTap: _redirectToMyPlaces),
      ButtonData(text: "My Trails", onTap: onTap),
      ButtonData(text: "Contact us", onTap: onTap),
    ];
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _clearAccessKeyAndRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("access");
    setState(() {
      // Refresh the page by resetting the future to reload the data
      _futureAccess = _loadCounter("access");
    });
  }

  void _redirectToMyPlaces() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPlaces()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text("Profile"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const ProfileInfoBox(
                username: "Test Value",
                email: "test.wp.pl",
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: buttonsData
                      .map((buttonData) => ProfileButton(
                          onTap: buttonData.onTap, text: buttonData.text))
                      .toList(),
                ),
              ),
              const SizedBox(
                height: 120,
              ),
              SignInSignUpButton(
                  buttonText: "Sign Out", onTap: _clearAccessKeyAndRefresh),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  void onTap() {}
}
