import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/myTrails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrailEditForm extends StatefulWidget {
  final Trail trail;

  const TrailEditForm(this.trail, {super.key});

  @override
  State<TrailEditForm> createState() => _TrailEditFormState();
}

class _TrailEditFormState extends State<TrailEditForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _link1Controller = TextEditingController();
  final TextEditingController _link2Controller = TextEditingController();

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
    _selectedPeriod = widget.trail.period.toString();
    _selectedType = widget.trail.type.toString();
    _nameController.text = widget.trail.trailName;
    _descriptionController.text = widget.trail.description;
    _link1Controller.text = widget.trail.wikiLink;
    _link2Controller.text = widget.trail.topicLink;
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
      throw Exception(AppLocalizations.of(context)!.failedLoadTypes);
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
      throw Exception(AppLocalizations.of(context)!.failedLoadPeriods);
    }
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? token = await _futureAccess;
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken["user_id"].toString();
        Map<String, String> formData = {
          'path_name': _nameController.text,
          'type': _selectedType,
          'period': _selectedPeriod,
          'description': _descriptionController.text,
          'wiki_link': _link1Controller.text,
          'topic_link': _link2Controller.text,
          'user': userId,
        };

        try {
          var response = await http.put(
            Uri.parse(
                'http://localhost:8000/memo_places/path/${widget.trail.id}/'),
            body: formData,
          );

          if (response.statusCode == 200) {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.succesAddedTrail,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: const Color.fromARGB(200, 76, 175, 79),
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyTrails()),
            );
          } else {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.alertError,
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

  Type? _getTypeById(String id) {
    for (var type in _types) {
      if (type.id.toString() == id) {
        return type;
      }
    }
    return null;
  }

  Period? _getPeriodById(String id) {
    for (var period in _periods) {
      if (period.id.toString() == id) {
        return period;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _types.sort((a, b) => a.order.compareTo(b.order));
    _periods.sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.editTrail,
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700),
        ),
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
                    return AppLocalizations.of(context)!.fieldInfo;
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
                value: _getTypeById(_selectedType),
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.plsSelectType;
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
                hint: Text(AppLocalizations.of(context)!.selectPeriod),
                value: _getPeriodById(_selectedPeriod),
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.plsSelectPeriod;
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
                    labelText: AppLocalizations.of(context)!.description,
                    counterText: '${_descriptionController.text.length}/1000'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.fieldInfo;
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