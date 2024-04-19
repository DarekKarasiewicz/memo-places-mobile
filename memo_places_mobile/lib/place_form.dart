import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class PlaceForm extends StatefulWidget {
  const PlaceForm({Key? key});

  @override
  _PlaceFormState createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _lengthController = TextEditingController();
  TextEditingController _widthController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _periodController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _link1Controller = TextEditingController();
  TextEditingController _link2Controller = TextEditingController();

  late Future<String?> _futureAccess;
  late Future<List<String>> _futureTypes;
  late Future<List<String>> _futurePeriods;
  late Future<List<String>> _futureSortof;
  late String _dropdownSortof;
  late String _dropdownPeriod;
  late String _dropdownType;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _futureTypes = _fetchTypes();
    _futurePeriods = _fetchPeriods();
    _futureSortof = _fetchSortof();
    _dropdownSortof = '1'; 
    _dropdownPeriod = '1'; 
    _dropdownType = '1'; 
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _getLocationAndFillFields() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission ==LocationPermission.denied){
      LocationPermission permission = await Geolocator.checkPermission();
      if(permission ==LocationPermission.denied){
        return Future.error("Location permission are denied");
      }
    }
    if(permission == LocationPermission.deniedForever){
        return Future.error("Location permission are denied permanently");
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _lengthController.text = position.latitude.toString();
        _widthController.text = position.longitude.toString();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<List<String>> _fetchTypes() async {
    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/types/'));
      if (response.statusCode == 200) {
        List<String> types = [];
        List<dynamic> data = json.decode(response.body);
        for (var item in data) {
          types.add(item['value'].toString());
        }
        print(types.toList().length);

        return types;
      } else {
        throw Exception('Failed to fetch types');
      }
    } catch (e) {
      throw Exception('Failed to fetch types: $e');
    }
  }
  Future<List<String>> _fetchPeriods() async {
    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/periods/'));
      if (response.statusCode == 200) {
        List<String> types = [];
        List<dynamic> data = json.decode(response.body);
        for (var item in data) {
          types.add(item['value'].toString());
        }
        print(types.toList().length);

        return types;
      } else {
        throw Exception('Failed to fetch types');
      }
    } catch (e) {
      throw Exception('Failed to fetch types: $e');
    }
  }
  Future<List<String>> _fetchSortof() async {
    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:8000/admin_dashboard/sortofs/'));
      if (response.statusCode == 200) {
        List<String> types = [];
        List<dynamic> data = json.decode(response.body);
        for (var item in data) {
          types.add(item['value'].toString());
        }
        print(types.toList().length);

        return types;
      } else {
        throw Exception('Failed to fetch types');
      }
    } catch (e) {
      throw Exception('Failed to fetch types: $e');
    }
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? token = await _futureAccess; 
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        Map<String, String> formData = {
          'place_name': _nameController.text,
          'found_date': _dateController.text,
          'lat': _lengthController.text,
          'lng': _widthController.text,
          'type': _categoryController.text, 
          'sortof': _categoryController.text,
          'period': _periodController.text,
          'description': _descriptionController.text,
          'wiki_link': _link1Controller.text,
          'topic_link': _link2Controller.text,
          'user': decodedToken['pk'].toString(),
        };

        try {
          var response = await http.post(
            Uri.parse('http://10.0.2.2:8000/memo_places/places/'),
            body: formData,
          );

          if (response.statusCode == 200) {
            print('Form sent successfully');
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
  return Scaffold(
    appBar: AppBar(
      title: Text('Place Form'),
    ),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: FutureBuilder<List<List<String>>>(
          future: Future.wait([_futureTypes, _futurePeriods, _futureSortof]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              List<List<String>> data = snapshot.data!;
              List<String> types = data[0];
              List<String> periods = data[1];
              List<String> sortofs = data[2];

              return ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lengthController,
                    decoration: InputDecoration(labelText: 'lng'),
                  ),
                  TextFormField(
                    controller: _widthController,
                    decoration: InputDecoration(labelText: 'lat'),
                  ),
                  ElevatedButton(
                    onPressed: _getLocationAndFillFields, 
                    child: Text('Get Location'),
                  ),
                  DropdownButtonFormField(
                    items: types.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _dropdownType = newValue!;
                      });
                    },
                    value: _dropdownType.isNotEmpty && types.contains(_dropdownType)
                        ? _dropdownType
                        : types.isNotEmpty
                            ? types[0]
                            : null,
                    decoration: InputDecoration(labelText: 'Category'), // Add decoration
                  ),
                  DropdownButtonFormField(
                    items: periods.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _dropdownPeriod = newValue!;
                      });
                    },
                    value: _dropdownPeriod.isNotEmpty && periods.contains(_dropdownPeriod)
                        ? _dropdownPeriod
                        : periods.isNotEmpty
                            ? periods[0]
                            : null,
                    decoration: InputDecoration(labelText: 'Period'),
                  ),
                  DropdownButtonFormField(
                    items: sortofs.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _dropdownSortof = newValue!;
                      });
                    },
                    value: _dropdownSortof.isNotEmpty && sortofs.contains(_dropdownSortof)
                        ? _dropdownSortof
                        : sortofs.isNotEmpty
                            ? sortofs[0]
                            : null,
                    decoration: InputDecoration(labelText: 'Sortof'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: _link1Controller,
                    decoration: InputDecoration(labelText: 'Link 1'),
                  ),
                  TextFormField(
                    controller: _link2Controller,
                    decoration: InputDecoration(labelText: 'Link 2'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _submitForm(context),
                    child: Text('Save'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    ),
  );
}
}