import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memo_places_mobile/home.dart';
import 'package:memo_places_mobile/profile.dart';
import 'package:memo_places_mobile/login.dart';
import 'package:memo_places_mobile/place_form.dart';

void main(){
  runApp(Main());
}

class Main extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Main> {
  int currentIndex = 0;
  final screens= [
    Home(),
    Profile(),
    PlaceForm(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              label: 'Home' ,
              icon: Icon(Icons.home,
                         size: 27)
              ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.account_box_outlined,
                         size:27)
              ),
            BottomNavigationBarItem(
              label: 'Form',
              icon: Icon(Icons.account_box_outlined,
                         size:27)
              ),
          ],
          currentIndex: currentIndex,
          onTap: (int index){
            setState((){
              currentIndex=index;
            });
          },
        ),
        ),
    );
  }
}