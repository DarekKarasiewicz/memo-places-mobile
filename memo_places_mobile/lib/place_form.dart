import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TextEditingController _typeController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _periodController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _link1Controller = TextEditingController();
  TextEditingController _link2Controller = TextEditingController();

  late Future<String?> _futureAccess = _loadCounter("access");

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? token = await _futureAccess; // Await the result of _futureAccess
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        Map<String, String> formData = {
          'place_name': _nameController.text,
          'found_date': _dateController.text,
          'lat': _lengthController.text,
          'lng': _widthController.text,
          'type': _typeController.text,
          'sortof': _categoryController.text,
          'period': _periodController.text,
          'description': _descriptionController.text,
          'wiki_link': _link1Controller.text,
          'topic_link': _link2Controller.text,
          'user': decodedToken['pk'].toString(),
        };

        // Send data to endpoint
        try {
          var response = await http.post(
            Uri.parse('http://10.0.2.2:8000/memo_places/places/'),
            body: formData,
          );

          // Handle response
          if (response.statusCode == 200) {
            // Handle success
            print('Form sent successfully');
          } else {
            // Handle error
            print('Error sending form: ${response.statusCode}');
          }
        } catch (e) {
          // Handle error
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
        title: Text('Formularz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nazwa'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Pole nazwa jest wymagane';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Data'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Pole data jest wymagane';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lengthController,
                decoration: InputDecoration(labelText: 'Długość'),
              ),
              TextFormField(
                controller: _widthController,
                decoration: InputDecoration(labelText: 'Szerokość'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Rodzaj'),
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Typ'),
              ),
              TextFormField(
                controller: _periodController,
                decoration: InputDecoration(labelText: 'Okres'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Opis'),
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
                child: Text('Zapisz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}