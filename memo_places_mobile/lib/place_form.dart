import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/sortof.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceForm extends StatefulWidget {
  const PlaceForm(this.position, {super.key});
  final LatLng position;

  @override
  _PlaceFormState createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _link1Controller = TextEditingController();
  TextEditingController _link2Controller = TextEditingController();

  late Future<String?> _futureAccess;
  List<Type> _types = [];
  List<Period> _periods = [];
  List<Sortof> _sortofs = [];
  late String _selectedSortof;
  late String _selectedPeriod;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _fetchTypes();
    _fetchPeriods();
    _fetchSortof();
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _fetchTypes() async {
    print(DateTime.now());
    var response = await http
        .get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/types/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _types = jsonData.map((data) => Type.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to fetch types');
    }
  }

  Future<void> _fetchPeriods() async {
    var response = await http
        .get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/periods/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _periods = jsonData.map((data) => Period.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to fetch types');
    }
  }

  Future<void> _fetchSortof() async {
    var response = await http
        .get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/sortofs/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _sortofs = jsonData.map((data) => Sortof.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to fetch types');
    }
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? token = await _futureAccess;
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        Map<String, String> formData = {
          'place_name': _nameController.text,
          'found_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'lat': widget.position.latitude.toString(),
          'lng': widget.position.longitude.toString(),
          'type': _selectedType,
          'sortof': _selectedSortof,
          'period': _selectedPeriod,
          'description': _descriptionController.text,
          'wiki_link': _link1Controller.text,
          'topic_link': _link2Controller.text,
          'user': "1",
        };

        try {
          var response = await http.post(
            Uri.parse('http://10.0.2.2:8000/memo_places/places/'),
            body: formData,
          );

          if (response.statusCode == 200) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else {
            print('Error sending form: ${response.statusCode}');
          }
        } catch (e) {
          print('Error sending form: $e');
        }
      } else {
        print('Error: JWT token is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _types.sort((a, b) => a.order.compareTo(b.order));
    _sortofs.sort((a, b) => a.order.compareTo(b.order));
    _periods.sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Field is required';
                  }
                  final RegExp nameRegex = RegExp(r'^[\w\d\s\(\)\"\:\-]+$');

                  if (!nameRegex.hasMatch(value)) {
                    return 'Invalid name format';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<Type>(
                hint: const Text('Select Type'),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a type';
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
              DropdownButtonFormField<Sortof>(
                hint: const Text('Select Sortof'),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a sortof';
                  }
                  return null;
                },
                onChanged: (Sortof? newValue) {
                  setState(() {
                    _selectedSortof = newValue!.id.toString();
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
                hint: const Text('Select Period'),
                value: null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a period';
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
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                    labelText: 'Description',
                    counterText: '${_descriptionController.text.length}/1000'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _link1Controller,
                decoration: const InputDecoration(labelText: 'Link 1'),
              ),
              TextFormField(
                controller: _link2Controller,
                decoration: const InputDecoration(labelText: 'Link 2'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
