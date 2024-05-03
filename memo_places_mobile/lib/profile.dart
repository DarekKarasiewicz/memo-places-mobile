import 'package:flutter/material.dart';
import 'package:memo_places_mobile/profile_my_places.dart';
import 'package:memo_places_mobile/signInOrSignUpPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<String?> _futureAccess = _loadCounter("access");

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _clearAccessKeyAndRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("access");
    setState(() {
      // Refresh the page by resetting the future to reload the data
      _futureAccess = _loadCounter("access");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text("Profile"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                      child: Image.network(
                    'https://pbs.twimg.com/profile_images/794107415876747264/g5fWe6Oh_400x400.jpg',
                    loadingBuilder: (context, child, loadingProgress) {
                      return loadingProgress == null
                          ? child
                          : LinearProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null);
                    },
                  ))),
              FutureBuilder(
                future: _futureAccess,
                builder: (context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    Map<String, dynamic> decodedToken =
                        JwtDecoder.decode(snapshot.data!);
                    return Text(
                      decodedToken["email"],
                      style: TextStyle(fontSize: 16),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      "Error loading data",
                      style: TextStyle(fontSize: 16),
                    );
                  } else {
                    return Text(
                      "Login to see data",
                      style: TextStyle(fontSize: 16),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignInOrSingUpPage()),
                  );
                },
                child: Text('Edit profile'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignInOrSingUpPage()),
                  );
                },
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyPlaces()),
                  );
                },
                child: Text('My places'),
              ),
              TextButton(
                onPressed: () {
                  _clearAccessKeyAndRefresh();
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
