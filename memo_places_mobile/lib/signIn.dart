import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpSwitchButton.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/authTile.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/hidePassword.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInAndSignUpTextField.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/forgotPasswordPage.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:memo_places_mobile/main.dart';
import 'package:memo_places_mobile/services/googleSignInApi.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    await GoogleSignInApi.signIn();
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
            msg: AppLocalizations.of(context)!.succesSignedIn,
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
          msg: AppLocalizations.of(context)!.badCredentials,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(197, 230, 45, 31),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.alertError,
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
          backgroundColor: Colors.lightBlue,
          title: Text(AppLocalizations.of(context)!.signIn),
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
                        hintText: AppLocalizations.of(context)!.enterEmail,
                        obscureText: false,
                        icon: const Icon(Icons.email)),
                    const SizedBox(height: 20),
                    SignInAndSignUpTextField(
                      controller: passwordController,
                      hintText: AppLocalizations.of(context)!.enterPass,
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
                                AppLocalizations.of(context)!.forgotPass,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ))
                      ],
                    ),
                    const SizedBox(height: 20),
                    SignInSignUpButton(
                        onTap: _login,
                        buttonText: AppLocalizations.of(context)!.signIn),
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
                            AppLocalizations.of(context)!.or,
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
      ),
    );
  }
}
