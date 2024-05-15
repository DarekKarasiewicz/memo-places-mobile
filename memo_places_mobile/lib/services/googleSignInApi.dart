import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> googleSignIn(BuildContext context) async {
  if (Platform.isIOS || Platform.isMacOS) {
    GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "584457314127-6adiqurs38ajbmouuh326gel87hiv77l.apps.googleusercontent.com",
        scopes: [
          'email',
        ],
        hostedDomain: "");

    final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      _checkGoogleAccountInBackend(context, googleAccount);
    }
  } else {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );

    final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

    if (googleAccount != null) {
      _checkGoogleAccountInBackend(context, googleAccount);
    }
  }
}

void _incrementCounter(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<void> _checkGoogleAccountInBackend(
    BuildContext context, GoogleSignInAccount googleAccount) async {
  try {
    var response = await http.get(
      Uri.parse(
          'http://localhost:8000/memo_places/users/email%3D${googleAccount.email.replaceAll(RegExp(r'\.'), '&')}/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseDecoded = json.decode(response.body);
      _incrementCounter('access', responseDecoded['access']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InternetChecker()),
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
    } else if (response.statusCode == 404) {
      var secondResponse = await http.post(
        Uri.parse('http://localhost:8000/memo_places/outside_users/'),
        body: jsonEncode({
          'email': googleAccount.email,
          'username': googleAccount.displayName
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (secondResponse.statusCode == 200) {
        var secondResponseDecoded = json.decode(secondResponse.body);
        _incrementCounter("access", secondResponseDecoded['access']);
      } else {
        throw Exception(LocaleKeys.alert_error.tr());
      }
    } else {
      throw Exception(LocaleKeys.alert_error.tr());
    }
  } on Exception catch (error) {
    Fluttertoast.showToast(
      msg: error.toString(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color.fromARGB(197, 230, 45, 31),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
