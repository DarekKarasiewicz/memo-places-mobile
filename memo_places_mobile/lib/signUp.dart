import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpSwitchButton.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/authTile.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/hidePassword.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInAndSignUpTextField.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/infoAfterSignUpPage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  final void Function() togglePages;

  const SignUp({super.key, required this.togglePages});

  @override
  State<SignUp> createState() => _SignInState();
}

class _SignInState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String? _passwordErrorMsg;
  bool _isPasswordValid = false;
  String? _emailErrorMsg;
  bool _isEmailValid = false;
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

  Future<void> _signUp() async {
    String url = 'http://10.0.2.2:8000/memo_places/users/';
    String email = emailController.text;
    String password = passwordController.text;
    String username = usernameController.text;
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
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InfoAfterSignUpPage()),
        );
        Fluttertoast.showToast(
          msg: "Successfully created account!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(200, 76, 175, 79),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else if (response.statusCode == 400) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "User already exist!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(197, 230, 45, 31),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Something went wrong, try again later.",
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

  void emailValidator(String email) {
    RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email) || email.isEmpty) {
      setState(() {
        _emailErrorMsg = "Please enter a valid email address!";
        _isEmailValid = false;
      });
    } else {
      _emailErrorMsg = null;
      _isEmailValid = true;
    }
  }

  void passwordValidator(String password, String confPassword) {
    RegExp passwordRegex =
        RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*\W)(?!.* ).{8,}$');
    if (!passwordRegex.hasMatch(password) || password.isEmpty) {
      setState(() {
        _passwordErrorMsg = """
        Password must contains:
        - At least one digit
        - At least one uppercase letter
        - At least one special character
        - Minimum length of 8 characters
        """;
        _isPasswordValid = false;
      });
    } else if (password != confPassword) {
      setState(() {
        _passwordErrorMsg = "Password is not the same!";
        _isPasswordValid = false;
      });
    } else {
      setState(() {
        _passwordErrorMsg = null;
        _isPasswordValid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: const Text("Sign Up"),
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
                        controller: usernameController,
                        hintText: "Enter username",
                        obscureText: false,
                        icon: const Icon(Icons.account_circle)),
                    const SizedBox(height: 20),
                    SignInAndSignUpTextField(
                        errorText: _emailErrorMsg,
                        controller: emailController,
                        hintText: "Enter email",
                        obscureText: false,
                        icon: const Icon(Icons.email)),
                    const SizedBox(height: 20),
                    SignInAndSignUpTextField(
                      errorText: _passwordErrorMsg,
                      controller: passwordController,
                      hintText: "Enter password",
                      obscureText: _isPaswordHidden,
                      icon: const Icon(Icons.lock),
                    ),
                    const SizedBox(height: 20),
                    SignInAndSignUpTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm password",
                      obscureText: _isPaswordHidden,
                      icon: const Icon(Icons.lock),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        HidePassword(
                          isPasswordHidden: _isPaswordHidden,
                          onHiddenChange: changeHidden,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SignInSignUpButton(
                        onTap: () {
                          passwordValidator(passwordController.text,
                              confirmPasswordController.text);
                          emailValidator(emailController.text);
                          if (_isEmailValid && _isPasswordValid) {
                            _signUp();
                          }
                        },
                        buttonText: "Sign Up"),
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
                            "Or continue with",
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
                      height: 30,
                    ),
                    Center(
                        child: AuthTile(
                      imagePath: "lib/assets/images/googleIcon.png",
                      onTap: onPressed,
                    )),
                    const SizedBox(
                      height: 30,
                    ),
                    SignInSignUpSwitchButton(
                        isAccountCreated: false,
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

  void onPressed() {}
}
