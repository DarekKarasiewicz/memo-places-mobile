import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/buttonData.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileButton.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileInfoBox.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/contactUsForm.dart';
import 'package:memo_places_mobile/editProfile.dart';
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/mainPage.dart';
import 'package:memo_places_mobile/myPlaces.dart';
import 'package:memo_places_mobile/myTrails.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<String?> _futureAccess = _loadCounter("access");
  List<ButtonData> buttonsData = [];
  late User _user;
  late String? token;

  Future<void> _clearAccessKeyAndRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("access");
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeButtonsData();
  }

  void _initializeButtonsData() {
    buttonsData = [
      ButtonData(
          text: LocaleKeys.edit_profile.tr(), onTap: _redirectToEditProfile),
      ButtonData(text: LocaleKeys.my_places.tr(), onTap: _redirectToMyPlaces),
      ButtonData(text: LocaleKeys.my_trails.tr(), onTap: _redirectToMyTrails),
      ButtonData(text: LocaleKeys.contact_us.tr(), onTap: _redirectToContactUs),
    ];
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _loadUserData() async {
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(LocaleKeys.profile.tr()),
      ),
      body: FutureBuilder(
        future: _futureAccess,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
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
                      buttonText: LocaleKeys.sign_out.tr(),
                      onTap: _clearAccessKeyAndRefresh),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            );
          } else {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
