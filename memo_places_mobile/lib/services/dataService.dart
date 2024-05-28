import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/Objects/offlinePlace.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:memo_places_mobile/Objects/sortof.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'package:memo_places_mobile/customExeption.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Type>> fetchTypes(BuildContext context) async {
  var response =
      await http.get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/types/'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Type.fromJson(data)).toList();
  } else {
    throw CustomException(LocaleKeys.failed_load_types.tr());
  }
}

Future<List<Period>> fetchPeriods(BuildContext context) async {
  var response = await http
      .get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/periods/'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Period.fromJson(data)).toList();
  } else {
    throw CustomException(LocaleKeys.failed_load_periods.tr());
  }
}

Future<List<Sortof>> fetchSortof(BuildContext context) async {
  var response = await http
      .get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/sortofs/'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((data) => Sortof.fromJson(data)).toList();
  } else {
    throw CustomException(LocaleKeys.failed_load_sortof.tr());
  }
}

Future<List<String>> fetchPlaceImages(
    BuildContext context, String placeId) async {
  final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/memo_places/place_image/place=$placeId'));
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    List<String> imageUrls = [];
    for (var item in jsonData) {
      imageUrls.add(item['img']);
    }
    return imageUrls;
  } else {
    throw CustomException(LocaleKeys.alert_error.tr());
  }
}

Future<List<String>> fetchTrailImages(
    BuildContext context, String trailId) async {
  final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/memo_places/path_image/path=$trailId'));
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    List<String> imageUrls = [];
    for (var item in jsonData) {
      imageUrls.add(item['img']);
    }
    return imageUrls;
  } else {
    throw CustomException(LocaleKeys.alert_error.tr());
  }
}

Future<List<Trail>> fetchUserTrails(BuildContext context, String userId) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8000/memo_places/path/user=$userId'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    var fechedTrails = <Trail>[];
    for (var data in jsonData) {
      var trail = Trail.fromJson(data);
      trail.images = await fetchTrailImages(context, trail.id.toString());
      fechedTrails.add(trail);
    }
    return fechedTrails;
  } else {
    throw CustomException(LocaleKeys.failed_load_trails.tr());
  }
}

Future<List<Place>> fetchUserPlaces(BuildContext context, String userId) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8000/memo_places/places/user=$userId'));
  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    var fechedPlaces = <Place>[];
    for (var data in jsonData) {
      var place = Place.fromJson(data);
      place.images = await fetchPlaceImages(context, place.id.toString());
      fechedPlaces.add(place);
    }
    return fechedPlaces;
  } else {
    throw CustomException(LocaleKeys.failed_load_places.tr());
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

Future<User?> loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString('user');

  if (user == null) {
    return null;
  }

  Map<String, dynamic> userMap = jsonDecode(user);
  return User.fromJson(userMap);
}

void deleteLocalData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
