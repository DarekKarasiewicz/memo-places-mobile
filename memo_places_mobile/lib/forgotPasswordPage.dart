import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInAndSignUpTextField.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'dart:convert';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();

  Future<void> _resetPassword() async {
    String url = 'http://localhost:8000/admin_dashboard/reset_password/';
    String email = emailController.text;
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
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseDecoded = json.decode(response.body);
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: LocaleKeys.link_sent.tr(),
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
          msg: LocaleKeys.dont_have_account.tr(),
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
                  Text(
                    LocaleKeys.link_to_active_info.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SignInAndSignUpTextField(
                      controller: emailController,
                      hintText: LocaleKeys.enter_email.tr(),
                      obscureText: false,
                      icon: const Icon(Icons.email)),
                  const SizedBox(height: 20),
                  SignInSignUpButton(
                      onTap: _resetPassword,
                      buttonText: LocaleKeys.restart_password.tr()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
