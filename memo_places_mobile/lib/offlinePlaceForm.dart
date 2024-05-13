import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/offlinePlace.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/sortof.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/formWidgets/imageInput.dart';
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/services/dataService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfflinePlaceForm extends StatefulWidget {
  const OfflinePlaceForm(this.position, {super.key});
  final LatLng position;

  @override
  State<OfflinePlaceForm> createState() => _OfflinePlaceFormState();
}

class _OfflinePlaceFormState extends State<OfflinePlaceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _link1Controller = TextEditingController();
  final TextEditingController _link2Controller = TextEditingController();

  late Future<String?> _futureAccess;
  List<Type> _types = [];
  List<Period> _periods = [];
  List<Sortof> _sortofs = [];
  late int _selectedSortof;
  late int _selectedPeriod;
  late int _selectedType;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    loadTypesFromDevice().then((value) {
      setState(() {
        _types = value;
      });
    });
    loadPeriodsFromDevice().then((value) {
      setState(() {
        _periods = value;
      });
    });
    loadSortofsFromDevice().then((value) {
      setState(() {
        _sortofs = value;
      });
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

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? token = await _futureAccess;
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      int userId = decodedToken["user_id"];
      List<OfflinePlace> devicePlaces = await loadOfflinePlacesFromDevice();
      List<OfflinePlace> place = [];
      place.add(OfflinePlace(
          placeName: _nameController.text,
          description: _descriptionController.text,
          lat: widget.position.latitude,
          lng: widget.position.longitude,
          user: userId,
          sortof: _selectedSortof,
          type: _selectedType,
          period: _selectedPeriod));

      if (devicePlaces.isEmpty) {
        List<Map<String, dynamic>> jsonData =
            place.map((value) => value.toJson()).toList();
        _incrementCounter('places', jsonEncode(jsonData));
      } else {
        List<Map<String, dynamic>> jsonData =
            [...devicePlaces, ...place].map((value) => value.toJson()).toList();
        _incrementCounter('places', jsonEncode(jsonData));
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InternetChecker()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _types.sort((a, b) => a.order.compareTo(b.order));
    _sortofs.sort((a, b) => a.order.compareTo(b.order));
    _periods.sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.placeForm),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name),
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.fieldRequired;
                  }
                  final RegExp nameRegex = RegExp(r'^[\w\d\s\(\)\"\:\-]+$');

                  if (!nameRegex.hasMatch(value)) {
                    return AppLocalizations.of(context)!.invalidName;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<Type>(
                hint: Text(AppLocalizations.of(context)!.selectType),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.plsSelectType;
                  }
                  return null;
                },
                onChanged: (Type? newValue) {
                  setState(() {
                    _selectedType = newValue!.id;
                  });
                },
                items: _types.map<DropdownMenuItem<Type>>((Type type) {
                  return DropdownMenuItem<Type>(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<Sortof>(
                hint: Text(AppLocalizations.of(context)!.selectSortof),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.plsSelectSortof;
                  }
                  return null;
                },
                onChanged: (Sortof? newValue) {
                  setState(() {
                    _selectedSortof = newValue!.id;
                  });
                },
                items: _sortofs.map<DropdownMenuItem<Sortof>>((Sortof sortof) {
                  return DropdownMenuItem<Sortof>(
                    value: sortof,
                    child: Text(sortof.name),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<Period>(
                hint: Text(AppLocalizations.of(context)!.selectPeriod),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.plsSelectPeriod;
                  }
                  return null;
                },
                onChanged: (Period? newValue) {
                  setState(() {
                    _selectedPeriod = newValue!.id;
                  });
                },
                items: _periods.map<DropdownMenuItem<Period>>((Period period) {
                  return DropdownMenuItem<Period>(
                    value: period,
                    child: Text(period.name),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 15,
              ),
              const ImageInput(),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    counterText: '${_descriptionController.text.length}/1000'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.fieldRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _link1Controller,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.wikiLink),
              ),
              TextFormField(
                controller: _link2Controller,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.topicLink),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
