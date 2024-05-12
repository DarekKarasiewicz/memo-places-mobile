import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/buttonData.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileButton.dart';
import 'package:memo_places_mobile/ProfileWidgets/profileInfoBox.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/contactUsForm.dart';
import 'package:memo_places_mobile/editProfile.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:memo_places_mobile/myPlaces.dart';
import 'package:memo_places_mobile/myTrails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    setState(() {
      token = null;
    });
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
          text: AppLocalizations.of(context)!.editProfile,
          onTap: _redirectToEditProfile),
      ButtonData(
          text: AppLocalizations.of(context)!.myPlaces,
          onTap: _redirectToMyPlaces),
      ButtonData(
          text: AppLocalizations.of(context)!.myTrails,
          onTap: _redirectToMyTrails),
      ButtonData(
          text: AppLocalizations.of(context)!.contactUs,
          onTap: _redirectToContactUs),
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
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text(AppLocalizations.of(context)!.profile),
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
                  buttonText: AppLocalizations.of(context)!.signOut,
                  onTap: _clearAccessKeyAndRefresh),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
