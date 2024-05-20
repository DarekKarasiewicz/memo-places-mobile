import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/period.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/Objects/type.dart';
import 'package:memo_places_mobile/formWidgets/customButton.dart';
import 'package:memo_places_mobile/formWidgets/customFormInput.dart';
import 'package:memo_places_mobile/formWidgets/customTitle.dart';
import 'package:memo_places_mobile/myTrails.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _wikiLinkController = TextEditingController();
  final TextEditingController _topicLinkController = TextEditingController();

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
    _wikiLinkController.text = widget.trail.wikiLink;
    _topicLinkController.text = widget.trail.topicLink;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _wikiLinkController.dispose();
    _topicLinkController.dispose();
    super.dispose();
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
          'wiki_link': _wikiLinkController.text,
          'topic_link': _topicLinkController.text,
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
              msg: LocaleKeys.succes_added_trail.tr(),
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
              )),
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
                value: _getTypeById(_selectedType),
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
                      type.value.tr(),
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
                value: _getPeriodById(_selectedPeriod),
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
                      period.value.tr(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                }).toList(),
              ),
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
