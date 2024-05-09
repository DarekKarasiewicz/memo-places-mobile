import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'dart:io';

import 'package:memo_places_mobile/SignInAndSignUpWidgets/hidePassword.dart';
import 'package:memo_places_mobile/main.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile(this.user, {super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confPasswordController = TextEditingController();
  bool _isUsernameEmpty = false;
  bool _isPasswordValid = true;
  bool _isPaswordHidden = true;
  String? _passwordErrorMsg;
  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
  }

  void changeHidden() {
    setState(() {
      _isPaswordHidden = !_isPaswordHidden;
    });
  }

  void _getImageFromGallery() async {
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imgXFile;
    });
  }

  void _passwordValidator(String password, String confPassword) {
    RegExp passwordRegex =
        RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*\W)(?!.* ).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      setState(() {
        _passwordErrorMsg = """
        Password must contains:
        - At least one digit
        - At least one uppercase letter
        - At least one special character
        - Minimum length of 8 characters
        """;
        _isPasswordValid = false;
      });
    } else if (password != confPassword) {
      setState(() {
        _passwordErrorMsg = "Password is not the same!";
        _isPasswordValid = false;
      });
    } else {
      setState(() {
        _passwordErrorMsg = null;
        _isPasswordValid = true;
      });
    }
  }

  void _saveUserData() async {
    Map<String, String> formData = _passwordController.text.isEmpty
        ? {
            'username': _usernameController.text,
          }
        : {
            'username': _usernameController.text,
            'password': _passwordController.text,
          };

    try {
      var response = await http.post(
        //Need changes but waiting for Sebastian
        Uri.parse('http://10.0.2.2:8000/memo_places/places/'),
        body: formData,
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Changes successfully sent",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(200, 76, 175, 79),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Main()),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong, try again later",
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(
            "Edit your profile",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.transparent,
                  backgroundImage: imgXFile == null
                      ? const NetworkImage(
                              'https://pbs.twimg.com/profile_images/794107415876747264/g5fWe6Oh_400x400.jpg')
                          as ImageProvider
                      : FileImage(File(imgXFile!.path)),
                ),
                const SizedBox(
                  height: 20,
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
                  onPressed: _getImageFromGallery,
                  child: const Text(
                    "Change avatar",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Change username",
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _usernameController,
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
                      labelText: 'Username',
                      errorText: _isUsernameEmpty
                          ? 'This field can\'t be empty!'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Change password",
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPaswordHidden,
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
                            labelText: 'Password',
                            errorText: _passwordErrorMsg),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _confPasswordController,
                        obscureText: _isPaswordHidden,
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
                          labelText: 'Confirm password',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          HidePassword(
                            isPasswordHidden: _isPaswordHidden,
                            onHiddenChange: changeHidden,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
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
                    if (_passwordController.text.isNotEmpty ||
                        _confPasswordController.text.isNotEmpty) {
                      _passwordValidator(_passwordController.text,
                          _confPasswordController.text);
                    }

                    setState(() {
                      _isUsernameEmpty = _usernameController.text.isEmpty;
                      if (_passwordController.text.isEmpty &&
                          _confPasswordController.text.isEmpty) {
                        _passwordErrorMsg = null;
                        _isPasswordValid = true;
                      }
                    });

                    if (!_isUsernameEmpty && _isPasswordValid) {
                      _saveUserData();
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
