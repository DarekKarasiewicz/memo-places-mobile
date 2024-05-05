import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final void Function() onTap;
  final String text;

  const ProfileButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(width: 2, color: Colors.grey.shade500),
          ),
          color: Colors.grey.shade400),
      padding: const EdgeInsets.all(20),
      child: Center(
          child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
        ),
      )),
    );
  }
}
