import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/translations/codegen_loader.g.dart';

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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('pl'),
        Locale('de'),
        Locale('ru')
      ],
      assetLoader: const CodegenLoader(),
      path: 'lib/assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      darkTheme: darkTheme,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      home: const InternetChecker(),
    );
  }
}
