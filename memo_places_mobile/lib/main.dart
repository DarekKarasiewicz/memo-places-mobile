import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main(){
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 72, 135, 242),
          title: const Text('Hello World'),
        ),
        body: const Text( "Google maps"),
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
              )
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