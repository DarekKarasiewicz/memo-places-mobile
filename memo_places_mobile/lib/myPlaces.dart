import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/MyPlacesAndTrailsWidgets/myPlaceBox.dart';
import 'package:memo_places_mobile/placeDetails.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:memo_places_mobile/placeEditForm.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
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
          .get(Uri.parse('http://localhost:8000/memo_places/places/user=$id'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _places = jsonData.map((data) => Place.fromJson(data)).toList();
        });
      } else {
        throw Exception(LocaleKeys.failed_load_places.tr());
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
          title: Text(LocaleKeys.confirm.tr()),
          content: Text(
            LocaleKeys.delete_warning
                .tr(namedArgs: {'name': _places[index].placeName}),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(LocaleKeys.cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                _deletePlace(index);
                Navigator.pop(dialogContext);
              },
              child: Text(LocaleKeys.delete.tr()),
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
          title: Text(LocaleKeys.confirm.tr()),
          content: Text(LocaleKeys.edit_info.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(LocaleKeys.cancel.tr()),
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
              child: Text(LocaleKeys.ok.tr()),
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
        msg: LocaleKeys.place_deleted.tr(),
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
        msg: LocaleKeys.alert_error.tr(),
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
          LocaleKeys.your_places.tr(),
        ),
      ),
      body: _places.isEmpty
          ? Center(
              child: Text(
                LocaleKeys.no_place_added.tr(),
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
                          label: LocaleKeys.preview.tr(),
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
                          label: LocaleKeys.edit.tr(),
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            _showDeleteDialog(index);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_outlined,
                          label: LocaleKeys.delete.tr(),
                        )
                      ],
                    ),
                    child: MyPlaceBox(place: place));
              },
            ),
    );
  }
}
