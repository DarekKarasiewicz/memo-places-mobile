import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/buttonData.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileButton.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileInfoBox.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/contactUsForm.dart';
import 'package:memo_places_mobile/editProfile.dart';
import 'package:memo_places_mobile/myPlaces.dart';
import 'package:memo_places_mobile/myTrails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final Future<void> Function() clearAccessKeyAndRefresh;
  const Profile(this.clearAccessKeyAndRefresh, {super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<String?> _futureAccess = _loadCounter("access");
  List<ButtonData> buttonsData = [];
  late User _user;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _initializeButtonsData();
    _loadUserData();
  }

  void _initializeButtonsData() {
    buttonsData = [
      ButtonData(text: "Edit profile", onTap: _redirectToEditProfile),
      ButtonData(text: "My Places", onTap: _redirectToMyPlaces),
      ButtonData(text: "My Trails", onTap: _redirectToMyTrails),
      ButtonData(text: "Contact us", onTap: _redirectToContactUs),
    ];
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _loadUserData() async {
    String? token = await _futureAccess;
    setState(() {
      _user = User.fromJson(JwtDecoder.decode(token!));
    });
  }

  void _redirectToMyPlaces() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPlaces()),
    );
  }

  void _redirectToMyTrails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyTrails()),
    );
  }

  void _redirectToContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactUsForm()),
    );
  }

  void _redirectToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfile(_user)),
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
              ProfileInfoBox(
                username: _user.username,
                email: _user.email,
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
                  buttonText: "Sign Out",
                  onTap: widget.clearAccessKeyAndRefresh),
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
