import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/offlinePlace.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:memo_places_mobile/Objects/sortof.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/home.dart';
import 'package:memo_places_mobile/profile.dart';
import 'package:memo_places_mobile/services/dataService.dart';
import 'package:memo_places_mobile/signInOrSignUpPage.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Main> {
  late String? token;
  late String id;
  int currentIndex = 0;
  bool isLogged = false;
  late List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    screens = [
      const Home(),
      const Profile(),
    ];
    _loadCounter("access").then((value) {
      token = value;
      if (token != null) {
        isLogged = true;
        _syncTypeData();
        _syncPeriodsData();
        _syncSortofData();
        _syncPlaceData(token!);
      } else {
        isLogged = false;
      }
    });
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _incrementCounter(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> _syncPlaceData(String token) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userId = decodedToken["user_id"].toString();
    List<OfflinePlace> offlinePlaces = await loadOfflinePlacesFromDevice();
    if (offlinePlaces.isNotEmpty) {
      for (OfflinePlace offlinePlace in offlinePlaces) {
        Map<String, String> placeData = {
          'place_name': offlinePlace.placeName,
          'lat': offlinePlace.lat.toString(),
          'lng': offlinePlace.lng.toString(),
          'type': offlinePlace.type.toString(),
          'sortof': offlinePlace.sortof.toString(),
          'period': offlinePlace.period.toString(),
          'description': offlinePlace.description,
          'wiki_link': offlinePlace.wikiLink,
          'topic_link': offlinePlace.topicLink,
          'user': userId,
        };

        var response = await http.post(
          Uri.parse('http://localhost:8000/memo_places/places/'),
          body: placeData,
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: LocaleKeys.stored_places_upload_succes.tr(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color.fromARGB(200, 76, 175, 79),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          deleteLocalData('places');
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
    } else {
      return;
    }
  }

  Future<void> _syncTypeData() async {
    List<Type> cloudTypes = await fetchTypes(context);
    List<Map<String, dynamic>> typesJsonList =
        cloudTypes.map((type) => type.toJson()).toList();

    _incrementCounter("types", jsonEncode(typesJsonList));
  }

  Future<void> _syncPeriodsData() async {
    List<Period> cloudPeriods = await fetchPeriods(context);
    List<Map<String, dynamic>> periodsJsonList =
        cloudPeriods.map((period) => period.toJson()).toList();

    _incrementCounter("periods", jsonEncode(periodsJsonList));
  }

  Future<void> _syncSortofData() async {
    List<Sortof> cloudSortof = await fetchSortof(context);
    List<Map<String, dynamic>> sortofJsonList =
        cloudSortof.map((sortof) => sortof.toJson()).toList();

    _incrementCounter("sortofs", jsonEncode(sortofJsonList));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: isLogged ? screens[currentIndex] : const Home(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              label: LocaleKeys.home.tr(),
              icon: const Icon(Icons.home, size: 27),
            ),
            BottomNavigationBarItem(
              label: LocaleKeys.profile.tr(),
              icon: const Icon(Icons.account_box_outlined, size: 27),
            ),
          ],
          currentIndex: currentIndex,
          onTap: (int index) {
            if (index == 1 && !isLogged) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SignInOrSingUpPage()),
              );
            } else {
              setState(() {
                currentIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}
