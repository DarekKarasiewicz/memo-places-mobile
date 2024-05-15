import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/offlinePlace.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/sortof.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/formWidgets/formPictureSlider.dart';
import 'package:memo_places_mobile/formWidgets/imageInput.dart';
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/services/dataService.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late final List<File> _selectedImages = [];
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _link1Controller.dispose();
    _link2Controller.dispose();
    super.dispose();
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _selectPictures() async {
    final imagePicker = ImagePicker();
    final pickedImages =
        await imagePicker.pickMultiImage(limit: 3, imageQuality: 50);

    if (pickedImages.isEmpty) {
      return;
    }

    for (final pickedImage in pickedImages) {
      if (_selectedImages.length >= 3) {
        return;
      }
      setState(() {
        _selectedImages.add(File(pickedImage.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _types.sort((a, b) => a.order.compareTo(b.order));
    _sortofs.sort((a, b) => a.order.compareTo(b.order));
    _periods.sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.place_form.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: LocaleKeys.name.tr()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.field_required.tr();
                  }
                  final RegExp nameRegex = RegExp(r'^[\w\d\s\(\)\"\:\-]+$');

                  if (!nameRegex.hasMatch(value)) {
                    return LocaleKeys.invalid_name.tr();
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<Type>(
                hint: Text(LocaleKeys.select_type.tr()),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return LocaleKeys.pls_select_type.tr();
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
                hint: Text(LocaleKeys.select_sortof.tr()),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return LocaleKeys.pls_select_sortof.tr();
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
                hint: Text(LocaleKeys.select_period.tr()),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return LocaleKeys.pls_select_period.tr();
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
              const SizedBox(
                height: 20,
              ),
              _selectedImages.isEmpty
                  ? const SizedBox()
                  : FormPictureSlider(
                      images: _selectedImages, onImageRemoved: _removeImage),
              _selectedImages.length == 3
                  ? const SizedBox()
                  : ImageInput(
                      selectedImages: _selectedImages,
                      onImageAdd: _selectPictures),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                  labelText: LocaleKeys.description.tr(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.field_required.tr();
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _link1Controller,
                decoration:
                    InputDecoration(labelText: LocaleKeys.wiki_link.tr()),
              ),
              TextFormField(
                controller: _link2Controller,
                decoration:
                    InputDecoration(labelText: LocaleKeys.topic_link.tr()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text(LocaleKeys.save.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
