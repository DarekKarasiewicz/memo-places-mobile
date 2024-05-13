import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:memo_places_mobile/MyPlacesAndTrailsWidgets/offlinePlaceBox.dart';
import 'package:memo_places_mobile/Objects/offlinePlace.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:memo_places_mobile/services/dataService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflinePlacesList extends StatefulWidget {
  const OfflinePlacesList({super.key});

  @override
  State<OfflinePlacesList> createState() => _OfflinePlacesListState();
}

class _OfflinePlacesListState extends State<OfflinePlacesList> {
  late List<OfflinePlace> places;

  @override
  void initState() {
    super.initState();
    loadOfflinePlacesFromDevice().then((value) {
      setState(() {
        places = value;
      });
    });
  }

  void _incrementCounter(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
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
                .deleteWarning(places[index].placeName),
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

  Future<void> _deletePlace(int index) async {
    setState(() {
      places.removeAt(index);
      List<Map<String, dynamic>> jsonData =
          places.map((value) => value.toJson()).toList();
      _incrementCounter('places', jsonEncode(jsonData));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 400,
        width: double.infinity,
        child: FutureBuilder(
          future: Future.wait([loadOfflinePlacesFromDevice()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return places.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.noPlaceAdded,
                        style: TextStyle(
                            fontSize: 24, color: Colors.grey.shade700),
                      ),
                    )
                  : ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final place = places[index];
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
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
                          child: OfflinePlaceBox(
                            name: place.placeName,
                          ),
                        );
                      },
                    );
            } else {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
          },
        ));
  }
}
