import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/MyPlacesAndTrailsWidgets/myPlaceBox.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:memo_places_mobile/placeDetails.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:memo_places_mobile/placeEditForm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          .get(Uri.parse('http://localhost:8000/memo_places/places/user=$id'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _places = jsonData.map((data) => Place.fromJson(data)).toList();
        });
      } else {
        throw Exception(AppLocalizations.of(context)!.failedLoadPlaces);
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
          title: Text(AppLocalizations.of(context)!.confirm),
          content: Text(
            AppLocalizations.of(context)!
                .deleteWarning(_places[index].placeName),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                _deletePlace(index);
                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.of(context)!.delete),
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
          title: Text(AppLocalizations.of(context)!.confirm),
          content: Text(AppLocalizations.of(context)!.editInfo),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceEditForm(_places[index]),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlace(int index) async {
    final response = await http.delete(Uri.parse(
        'http://localhost:8000/memo_places/places/${_places[index].id}/'));
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.placeDeleted,
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
        msg: AppLocalizations.of(context)!.alertError,
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.yourPlaces,
        ),
      ),
      body: _places.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.noPlaceAdded,
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
                                  builder: (context) => PlaceDetails(place)),
                            );
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.arrow_forward,
                          label: AppLocalizations.of(context)!.preview,
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
                          label: AppLocalizations.of(context)!.edit,
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            _showDeleteDialog(index);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_outlined,
                          label: AppLocalizations.of(context)!.delete,
                        )
                      ],
                    ),
                    child: MyPlaceBox(place: place));
              },
            ),
    );
  }
}
