import 'package:flutter/material.dart';

class SignInAndSignUpTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon icon;
  final String? errorText;

  const SignInAndSignUpTextField(
      {required this.controller,
      this.errorText,
      required this.hintText,
      required this.obscureText,
      required this.icon,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          errorText: errorText,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: icon,
          prefixIconColor: Colors.grey.shade500,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true),
      obscureText: obscureText,
    );
  }
}
