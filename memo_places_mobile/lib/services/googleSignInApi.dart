import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'package:memo_places_mobile/customExeption.dart';
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/toasts.dart';
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
    );

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
          'http://10.0.2.2:8000/memo_places/users/email%3D${googleAccount.email.replaceAll(RegExp(r'\.'), '&')}/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      User user = User.fromJson(JwtDecoder.decode(response.body));
      _incrementCounter("user", jsonEncode(user));
      showSuccesToast(LocaleKeys.succes_signed_in.tr());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InternetChecker()),
      );
    } else if (response.statusCode == 404) {
      var secondResponse = await http.post(
        Uri.parse('http://10.0.2.2:8000/memo_places/outside_users/'),
        body: jsonEncode({
          'email': googleAccount.email,
          'username': googleAccount.displayName
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (secondResponse.statusCode == 200) {
        User user = User.fromJson(JwtDecoder.decode(secondResponse.body));
        _incrementCounter("user", jsonEncode(user));
        showSuccesToast(LocaleKeys.succes_signed_in.tr());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InternetChecker()),
        );
      } else {
        throw CustomException(LocaleKeys.alert_error.tr());
      }
    } else {
      throw CustomException(LocaleKeys.alert_error.tr());
    }
  } on CustomException catch (error) {
    showErrorToast(error.toString());
  }
}
