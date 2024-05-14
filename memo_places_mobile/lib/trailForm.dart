import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/formWidgets/formPictureSlider.dart';
import 'package:memo_places_mobile/formWidgets/imageInput.dart';
import 'package:memo_places_mobile/home.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrailForm extends StatefulWidget {
  final List<LatLng> trailCoordinates;
  final String distance;
  final String time;

  const TrailForm(
      {super.key,
      required this.trailCoordinates,
      required this.distance,
      required this.time});

  @override
  State<StatefulWidget> createState() => _TrailFormState();
}

class _TrailFormState extends State<TrailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _link1Controller = TextEditingController();
  final TextEditingController _link2Controller = TextEditingController();

  late final List<File> _selectedImages = [];
  late Future<String?> _futureAccess;
  List<Type> _types = [];
  List<Period> _periods = [];
  late String _selectedPeriod;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _fetchTypes();
    _fetchPeriods();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _descriptionController.text = LocaleKeys.time_and_distance
        .tr(namedArgs: {'time': widget.time, 'distance': widget.distance});
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _fetchTypes() async {
    var response = await http
        .get(Uri.parse('http://localhost:8000/admin_dashboard/types/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _types = jsonData.map((data) => Type.fromJson(data)).toList();
      });
    } else {
      throw Exception(LocaleKeys.failed_load_types.tr());
    }
  }

  Future<void> _fetchPeriods() async {
    var response = await http
        .get(Uri.parse('http://localhost:8000/admin_dashboard/periods/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _periods = jsonData.map((data) => Period.fromJson(data)).toList();
      });
    } else {
      throw Exception(LocaleKeys.failed_load_periods.tr());
    }
  }

  List<LatLng> removeDuplicates(List<LatLng> latLngList) {
    Set<LatLng> uniqueLatLngSet = {};

    for (LatLng latLng in latLngList) {
      uniqueLatLngSet.add(latLng);
    }

    return uniqueLatLngSet.toList();
  }

  String convertLatLngToJson(List<LatLng> latLngList) {
    List<Map<String, double>> listOfMaps = latLngList.map((latLng) {
      return {
        'lat': latLng.latitude,
        'lng': latLng.longitude,
      };
    }).toList();

    return jsonEncode(listOfMaps);
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? token = await _futureAccess;
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken["user_id"].toString();

        Map<String, String> formData = {
          'path_name': _nameController.text,
          'coordinates':
              convertLatLngToJson(removeDuplicates(widget.trailCoordinates)),
          'type': _selectedType,
          'period': _selectedPeriod,
          'description': _descriptionController.text,
          'wiki_link': _link1Controller.text,
          'topic_link': _link2Controller.text,
          'user': userId,
        };

        try {
          var response = await http.post(
            Uri.parse('http://localhost:8000/memo_places/path/'),
            body: formData,
          );

          if (response.statusCode == 200) {
            Fluttertoast.showToast(
              msg: LocaleKeys.succes_trail_added.tr(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: const Color.fromARGB(200, 76, 175, 79),
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
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
        } catch (e) {
          print('Error sending form: $e');
        }
      } else {
        print('Error: JWT token is null');
      }
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
    _periods.sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.trail_form.tr()),
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
                    return LocaleKeys.field_info.tr();
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
                    _selectedType = newValue!.id.toString();
                  });
                },
                items: _types.map<DropdownMenuItem<Type>>((Type type) {
                  return DropdownMenuItem<Type>(
                    value: type,
                    child: Text(type.name),
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
                    _selectedPeriod = newValue!.id.toString();
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
                    counterText: '${_descriptionController.text.length}/1000'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.field_info.tr();
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
