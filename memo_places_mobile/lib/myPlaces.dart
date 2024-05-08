import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/MyPlacesAndTrailsWidgets/myPlaceBox.dart';
import 'package:memo_places_mobile/placeDetails.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPlaces extends StatefulWidget {
  const MyPlaces({super.key});

  @override
  State<MyPlaces> createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> {
  late List<Place> _places = [];
  late Future<String?> _futureAccess;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _fetchUserPlaces();
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _fetchUserPlaces() async {
    String? access = await _futureAccess;
    if (access != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(access);
      String id = decodedToken["user_id"].toString();
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/memo_places/places/user=$id'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _places = jsonData.map((data) => Place.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load places data');
      }
    } else {
      throw Exception('Access token is null');
    }
  }

  void _showDeleteDialog(int index) {
    BuildContext dialogContext;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;

        return AlertDialog(
          title: const Text("Confirm"),
          content: Text(
              "Are you sure you want to delete ${_places[index].placeName}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deletePlace(index);
                Navigator.pop(dialogContext);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlace(int index) async {
    final response = await http.delete(Uri.parse(
        'http://10.0.2.2:8000/memo_places/places/${_places[index].id}'));
    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: "Place deleted",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(200, 76, 175, 79),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        _places.removeAt(index);
      });
    } else {
      Fluttertoast.showToast(
        msg: "Something went wrong, try again later.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(197, 230, 45, 31),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.grey.shade300,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text(
              "Your Places",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700),
            ),
          ),
          body: _places.isEmpty
              ? Center(
                  child: Text(
                    "No place added",
                    style: TextStyle(fontSize: 24, color: Colors.grey.shade700),
                  ),
                )
              : ListView.builder(
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    return Slidable(
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PlaceDetails(place)),
                                );
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.arrow_forward,
                              label: "Preview",
                            )
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              //TODO editing page
                              onPressed: onPressed,
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.edit_location_alt_outlined,
                              label: "Edit",
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                _showDeleteDialog(index);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_outlined,
                              label: "Delete",
                            )
                          ],
                        ),
                        child: MyPlaceBox(place: place));
                  },
                )),
    );
  }

  void onPressed(BuildContext context) {}
}
