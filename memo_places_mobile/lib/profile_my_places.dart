import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPlaces extends StatefulWidget {
  const MyPlaces({Key? key}) : super(key: key);

  @override
  State<MyPlaces> createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> {
  late Future<List<Map<String, dynamic>>> _placesData;
  late Future<String?> _futureAccess;

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<List<Map<String, dynamic>>> _fetchPlacesData() async {
    String? access = await _futureAccess;
    if (access != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(access);
      String email = decodedToken["email"].toString();
      email = email.replaceAll('.', '&');
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/memo_places/places/email=' + email));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data.map((e) => e as Map<String, dynamic>));
      } else {
        throw Exception('Failed to load places data');
      }
    } else {
      throw Exception('Access token is null');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _placesData = _fetchPlacesData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _placesData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final places = snapshot.data!;
                return Column(
                  children: [
                    Text("Welcome here"),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(places[index].toString()),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
