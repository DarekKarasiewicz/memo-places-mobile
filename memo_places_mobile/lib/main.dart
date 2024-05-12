import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memo_places_mobile/home.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:memo_places_mobile/profile.dart';
import 'package:memo_places_mobile/signInOrSignUpPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MaterialApp(
    supportedLocales: L10n.all,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    home: const Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Main> {
  late String? token;
  int currentIndex = 0;
  bool isLogged = false;
  late List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    screens = [
      const Home(),
      const Profile(),
    ];
    _loadCounter("access").then((value) {
      token = value;
      if (token != null) {
        isLogged = true;
      } else {
        isLogged = false;
      }
    });
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
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
      home: Scaffold(
        body: isLogged ? screens[currentIndex] : const Home(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              label: AppLocalizations.of(context)!.home,
              icon: const Icon(Icons.home, size: 27),
            ),
            BottomNavigationBarItem(
              label: AppLocalizations.of(context)!.profile,
              icon: const Icon(Icons.account_box_outlined, size: 27),
            ),
          ],
          currentIndex: currentIndex,
          onTap: (int index) {
            if (index == 1 && !isLogged) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SignInOrSingUpPage()),
              );
            } else {
              setState(() {
                currentIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}
