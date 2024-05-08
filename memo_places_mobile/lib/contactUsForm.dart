import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late Future<String?> _futureAccess;
  late User _user;

  @override
  void initState() {
    super.initState();
    _futureAccess = _loadCounter("access");
    _loadUserData();
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _loadUserData() async {
    String? token = await _futureAccess;
    setState(() {
      _user = User.fromJson(JwtDecoder.decode(token!));
    });
  }

  void _sendMessage() async {
    Map<String, String> formData = {
      'email': _user.email,
      'title': _titleController.text,
      'desc': _messageController.text,
    };

    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/memo_places/contact_us/'),
        body: formData,
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Message successfully sent',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(200, 76, 175, 79),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: 'Something went wrong, try again later',
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade300,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Contact Us',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
        ),
        body: Center(
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
                    labelText: 'Title',
                    hintText: 'Enter a title',
                    errorText:
                        _isTitleEmpty ? 'This field can\'t be empty!' : null,
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
                    labelText: 'Message',
                    hintText: 'Enter your message here ...',
                    errorText:
                        _isMessageEmpty ? 'This field can\'t be empty!' : null,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all(Colors.grey.shade800),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey.shade700),
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
                  child: const Text(
                    "Send message",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
