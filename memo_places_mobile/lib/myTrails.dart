import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/MyPlacesAndTrailsWidgets/myTrailBox.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/trailDetails.dart';
import 'package:memo_places_mobile/trailEditForm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTrails extends StatefulWidget {
  const MyTrails({super.key});

  @override
  State<MyTrails> createState() => _MyTrailsState();
}

class _MyTrailsState extends State<MyTrails> {
  late List<Trail> _trails = [];
  late Future<String?> _futureAccess;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _fetchUserTrails();
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _fetchUserTrails() async {
    String? access = await _futureAccess;
    if (access != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(access);
      String id = decodedToken["user_id"].toString();
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/memo_places/path/user=$id'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _trails = jsonData.map((data) => Trail.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load trails data');
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
              "Are you sure you want to delete ${_trails[index].trailName}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteTrail(index);
                Navigator.pop(dialogContext);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(int index) {
    BuildContext dialogContext;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;

        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text(
              "You will be able only to edit basic information, for more editing options please visit our website."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrailEditForm(_trails[index]),
                  ),
                );
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTrail(int index) async {
    final response = await http.delete(Uri.parse(
        'http://10.0.2.2:8000/memo_places/path/${_trails[index].id}'));
    if (response.statusCode == 301) {
      Fluttertoast.showToast(
        msg: "Trail deleted",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(200, 76, 175, 79),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        _trails.removeAt(index);
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
            "Your Trails",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
        ),
        body: _trails.isEmpty
            ? Center(
                child: Text(
                  "No trails added",
                  style: TextStyle(fontSize: 24, color: Colors.grey.shade700),
                ),
              )
            : ListView.builder(
                itemCount: _trails.length,
                itemBuilder: (context, index) {
                  final trail = _trails[index];
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
                                    builder: (context) => TrailDetails(trail)),
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
                            onPressed: (context) {
                              _showEditDialog(index);
                            },
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
                      child: MyTrailBox(trail: trail));
                },
              ),
      ),
    );
  }

  void onPressed(BuildContext context) {}
}
