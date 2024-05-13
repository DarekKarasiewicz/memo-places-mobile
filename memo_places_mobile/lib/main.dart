import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var colorScheme = ColorScheme.fromSeed(seedColor: Colors.grey.shade300);
var lightTheme = ThemeData().copyWith(
  scaffoldBackgroundColor: Colors.grey.shade300,
  appBarTheme: const AppBarTheme().copyWith(
    centerTitle: true,
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Colors.grey.shade700,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
      foregroundColor: Colors.grey.shade700,
      backgroundColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      )),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
      backgroundColor: Colors.grey.shade400,
      unselectedItemColor: Colors.grey.shade700,
      selectedItemColor: Colors.black),
);

var darkTheme = ThemeData.dark().copyWith(
  appBarTheme: const AppBarTheme().copyWith(
    centerTitle: true,
    backgroundColor: Colors.transparent,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(28.0),
  )),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(),
);
void main() {
  runApp(MaterialApp(
    supportedLocales: L10n.all,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    darkTheme: darkTheme,
    theme: lightTheme,
    themeMode: ThemeMode.light,
    home: const InternetChecker(),
  ));
}
