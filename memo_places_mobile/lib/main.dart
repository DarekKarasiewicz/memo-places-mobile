import 'package:flutter/material.dart';
import 'package:memo_places_mobile/home.dart';
import 'package:memo_places_mobile/profile.dart';
import 'package:memo_places_mobile/signInOrSignUpPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: Main(),
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
  final screens = [
    const Home(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCounter("access").then((value) {
      token = value;
      if (token != null) {
        isLogged = true;
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: isLogged ? screens[currentIndex] : const Home(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home, size: 27),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.account_box_outlined, size: 27),
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
