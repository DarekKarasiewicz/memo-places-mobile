import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpSwitchButton.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/authTile.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/hidePassword.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInAndSignUpTextField.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/forgotPasswordPage.dart';
import 'package:memo_places_mobile/main.dart';
import 'package:memo_places_mobile/mainPage.dart';
import 'package:memo_places_mobile/services/googleSignInApi.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  final void Function() togglePages;

  const SignIn({super.key, required this.togglePages});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? _access;
  bool _isPaswordHidden = true;

  @override
  void initState() {
    super.initState();
  }

  void changeHidden() {
    setState(() {
      _isPaswordHidden = !_isPaswordHidden;
    });
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _incrementCounter(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> _googleSignIn() async {
    if (Platform.isIOS || Platform.isMacOS) {
      GoogleSignIn googleSignIn = GoogleSignIn(
          clientId:
              "584457314127-6adiqurs38ajbmouuh326gel87hiv77l.apps.googleusercontent.com",
          scopes: [
            'email',
          ],
          hostedDomain: "");

      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
    } else {
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );

      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
    }
  }

  Future<void> _login() async {
    String url = 'http://localhost:8000/memo_places/token/';
    String email = emailController.text;
    String password = passwordController.text;

    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseDecoded = json.decode(response.body);
        setState(() {
          _access = responseDecoded["access"];
          _incrementCounter("access", _access!);
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Main()),
          );
          Fluttertoast.showToast(
            msg: LocaleKeys.succes_signed_in.tr(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color.fromARGB(200, 76, 175, 79),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        });
      } else if (response.statusCode == 400) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: LocaleKeys.bad_credentials.tr(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(197, 230, 45, 31),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: LocaleKeys.alert_error.tr(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(197, 230, 45, 31),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.sign_in.tr()),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Logo",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SignInAndSignUpTextField(
                      controller: emailController,
                      hintText: LocaleKeys.enter_email.tr(),
                      obscureText: false,
                      icon: const Icon(Icons.email)),
                  const SizedBox(height: 20),
                  SignInAndSignUpTextField(
                    controller: passwordController,
                    hintText: LocaleKeys.enter_pass.tr(),
                    obscureText: _isPaswordHidden,
                    icon: const Icon(Icons.lock),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HidePassword(
                        isPasswordHidden: _isPaswordHidden,
                        onHiddenChange: changeHidden,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              LocaleKeys.forgot_pass.tr(),
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(height: 20),
                  SignInSignUpButton(
                      onTap: _login, buttonText: LocaleKeys.sign_in.tr()),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          LocaleKeys.or.tr(),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                      child: AuthTile(
                    imagePath: "lib/assets/images/googleIcon.png",
                    onTap: _googleSignIn,
                  )),
                  const SizedBox(
                    height: 160,
                  ),
                  SignInSignUpSwitchButton(
                      isAccountCreated: true,
                      loginRegisterSwitch: widget.togglePages),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
