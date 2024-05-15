import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:memo_places_mobile/Objects/user.dart';
import 'package:memo_places_mobile/customExeption.dart';
import 'package:memo_places_mobile/services/dataService.dart';
import 'package:memo_places_mobile/toasts.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

class ContactUsForm extends StatefulWidget {
  const ContactUsForm({super.key});

  @override
  State<ContactUsForm> createState() => _ContactUsFormState();
}

class _ContactUsFormState extends State<ContactUsForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isTitleEmpty = false;
  bool _isMessageEmpty = false;

  late User _user;

  @override
  void initState() {
    super.initState();
    loadUserData().then((value) => _user = value);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    Map<String, String> formData = {
      'email': _user.email,
      'title': _titleController.text,
      'description': _messageController.text,
    };

    try {
      var response = await http.post(
        Uri.parse('http://localhost:8000/memo_places/contact_us/'),
        body: formData,
      );

      if (response.statusCode == 200) {
        showSuccesToast(LocaleKeys.message_sent_succes.tr());
        Navigator.pop(context);
      } else {
        throw CustomException(LocaleKeys.alert_error.tr());
      }
    } on CustomException catch (error) {
      showErrorToast(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          LocaleKeys.contact_us.tr(),
        ),
      ),
      body: FutureBuilder(
        future: loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade700,
                              width: 1.5,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          labelStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold),
                          labelText: LocaleKeys.title.tr(),
                          hintText: LocaleKeys.enter_email.tr(),
                          errorText:
                              _isTitleEmpty ? LocaleKeys.field_info.tr() : null,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      TextField(
                        controller: _messageController,
                        maxLines: 5,
                        maxLength: 200,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade700,
                              width: 1.5,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          labelStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold),
                          labelText: LocaleKeys.message.tr(),
                          hintText: LocaleKeys.enter_message.tr(),
                          errorText: _isMessageEmpty
                              ? LocaleKeys.field_info.tr()
                              : null,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all(Colors.grey.shade800),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey.shade700),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15)),
                        ),
                        onPressed: () {
                          setState(() {
                            _isTitleEmpty = _titleController.text.isEmpty;
                            _isMessageEmpty = _messageController.text.isEmpty;
                          });

                          if (!_isTitleEmpty && !_isMessageEmpty) {
                            _sendMessage();
                          }
                        },
                        child: Text(
                          LocaleKeys.send_message.tr(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
