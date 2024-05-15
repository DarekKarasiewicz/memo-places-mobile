import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:memo_places_mobile/Objects/user.dart';
import 'dart:io';

import 'package:memo_places_mobile/customExeption.dart';
import 'package:memo_places_mobile/internetChecker.dart';
import 'package:memo_places_mobile/toasts.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile(this.user, {super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final bool _isUsernameEmpty = false;
  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _getImageFromGallery() async {
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imgXFile;
    });
  }

  void _saveUserData() async {
    try {
      var response = await http.post(
        Uri.parse('http://localhost:8000/memo_places/places/'),
        body: {
          'username': _usernameController.text,
        },
      );

      if (response.statusCode == 200) {
        showSuccesToast(LocaleKeys.changes_succes_sent.tr());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InternetChecker()),
        );
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
          LocaleKeys.edit_profile.tr(),
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
                  overlayColor: MaterialStateProperty.all(Colors.grey.shade800),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey.shade700),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                ),
                onPressed: _getImageFromGallery,
                child: Text(
                  LocaleKeys.change_avatar.tr(),
                  style: const TextStyle(
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
                LocaleKeys.change_username.tr(),
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
                    labelText: LocaleKeys.username.tr(),
                    errorText:
                        _isUsernameEmpty ? LocaleKeys.field_info.tr() : null,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.grey.shade800),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey.shade700),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                ),
                onPressed: () {
                  _saveUserData();
                },
                child: Text(
                  LocaleKeys.save.tr(),
                  style: const TextStyle(
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
    );
  }
}
