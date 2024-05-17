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
import 'package:memo_places_mobile/formWidgets/customButton.dart';
import 'package:memo_places_mobile/formWidgets/customFormInput.dart';
import 'package:memo_places_mobile/formWidgets/customTitle.dart';
import 'package:memo_places_mobile/formWidgets/formPictureSlider.dart';
import 'package:memo_places_mobile/formWidgets/imageInput.dart';
import 'package:memo_places_mobile/home.dart';
import 'package:memo_places_mobile/internetChecker.dart';
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
  final TextEditingController _wikiLinkController = TextEditingController();
  final TextEditingController _topicLinkController = TextEditingController();

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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _wikiLinkController.dispose();
    _topicLinkController.dispose();
    super.dispose();
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
          'wiki_link': _wikiLinkController.text,
          'topic_link': _topicLinkController.text,
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
              MaterialPageRoute(builder: (context) => const InternetChecker()),
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

  String? _descriptionValidator(String? fieldContent) {
    if (fieldContent!.isEmpty) {
      return LocaleKeys.field_required.tr();
    }
    return null;
  }

  String? _nameValidator(String? fieldContent) {
    if (fieldContent!.isEmpty) {
      return LocaleKeys.field_required.tr();
    }
    final RegExp nameRegex = RegExp(r'^[\w\d\s\(\)\"\:\-]+$');

    if (!nameRegex.hasMatch(fieldContent)) {
      return LocaleKeys.invalid_name.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _types.sort((a, b) => a.order.compareTo(b.order));
    _periods.sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: CustomTitle(
                  title: LocaleKeys.trail_form.tr(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomFormInput(
                controller: _nameController,
                label: LocaleKeys.name.tr(),
                validator: _nameValidator,
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField<Type>(
                decoration: InputDecoration(
                  labelText: LocaleKeys.select_type.tr(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.scrim,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 1,
                    ),
                  ),
                  labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
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
                    child: Text(
                      type.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField<Period>(
                decoration: InputDecoration(
                  labelText: LocaleKeys.select_period.tr(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.scrim,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 1,
                    ),
                  ),
                  labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
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
                    child: Text(
                      period.name,
                      style: const TextStyle(fontSize: 20),
                    ),
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
              const SizedBox(height: 20),
              CustomFormInput(
                maxLength: 1000,
                maxLines: 5,
                controller: _descriptionController,
                label: LocaleKeys.description.tr(),
                validator: _descriptionValidator,
              ),
              const SizedBox(height: 20),
              CustomFormInput(
                controller: _wikiLinkController,
                label: LocaleKeys.wiki_link.tr(),
              ),
              const SizedBox(height: 20),
              CustomFormInput(
                controller: _topicLinkController,
                label: LocaleKeys.topic_link.tr(),
              ),
              const SizedBox(height: 35),
              CustomButton(
                onPressed: () => _submitForm(context),
                text: LocaleKeys.save.tr(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
