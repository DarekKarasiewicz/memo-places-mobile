import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/Objects/offlinePlace.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:memo_places_mobile/Objects/sortof.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Type>> fetchTypes(BuildContext context) async {
  var response =
      await http.get(Uri.parse('http://localhost:8000/admin_dashboard/types/'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Type.fromJson(data)).toList();
  } else {
    throw Exception(AppLocalizations.of(context)!.failedLoadTypes);
  }
}

Future<List<Period>> fetchPeriods(BuildContext context) async {
  var response = await http
      .get(Uri.parse('http://localhost:8000/admin_dashboard/periods/'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Period.fromJson(data)).toList();
  } else {
    throw Exception(AppLocalizations.of(context)!.failedLoadPeriods);
  }
}

Future<List<Sortof>> fetchSortof(BuildContext context) async {
  var response = await http
      .get(Uri.parse('http://localhost:8000/admin_dashboard/sortofs/'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Sortof.fromJson(data)).toList();
  } else {
    throw Exception(AppLocalizations.of(context)!.failedLoadSortof);
  }
}

Future<List<Trail>> fetchUserTrails(BuildContext context, String userId) async {
  final response = await http
      .get(Uri.parse('http://localhost:8000/memo_places/path/user=$userId'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Trail.fromJson(data)).toList();
  } else {
    throw Exception(AppLocalizations.of(context)!.failedLoadTrails);
  }
}

Future<List<Place>> fetchUserPlaces(BuildContext context, String userId) async {
  final response = await http
      .get(Uri.parse('http://localhost:8000/memo_places/places/user=$userId'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Place.fromJson(data)).toList();
  } else {
    throw Exception(AppLocalizations.of(context)!.failedLoadPlaces);
  }
}

Future<List<Type>> loadTypesFromDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? typesJson = prefs.getString('types');
  List<Type> deviceTypes = [];
  if (typesJson != null) {
    List<dynamic> jsonList = jsonDecode(typesJson);
    deviceTypes = jsonList.map((json) => Type.fromJson(json)).toList();
  }
  return deviceTypes;
}

Future<List<Period>> loadPeriodsFromDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? periodsJson = prefs.getString('periods');
  List<Period> devicePeriods = [];
  if (periodsJson != null) {
    List<dynamic> jsonList = jsonDecode(periodsJson);
    devicePeriods = jsonList.map((json) => Period.fromJson(json)).toList();
  }
  return devicePeriods;
}

Future<List<Sortof>> loadSortofsFromDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sortofsJson = prefs.getString('sortofs');
  List<Sortof> deviceSortofs = [];
  if (sortofsJson != null) {
    List<dynamic> jsonList = jsonDecode(sortofsJson);
    deviceSortofs = jsonList.map((json) => Sortof.fromJson(json)).toList();
  }
  return deviceSortofs;
}

Future<List<OfflinePlace>> loadOfflinePlacesFromDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? offlinePlacesJson = prefs.getString('places');
  List<OfflinePlace> deviceOfflienPlaces = [];
  if (offlinePlacesJson != null) {
    List<dynamic> jsonList = jsonDecode(offlinePlacesJson);
    deviceOfflienPlaces =
        jsonList.map((json) => OfflinePlace.fromJson(json)).toList();
  }
  return deviceOfflienPlaces;
}

void deleteLocalData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
