import 'package:flutter/material.dart';

class SignInSignUpSwitchButton extends StatelessWidget {
  final bool isAccountCreated;
  final void Function() loginRegisterSwitch;

  const SignInSignUpSwitchButton(
      {super.key,
      required this.isAccountCreated,
      required this.loginRegisterSwitch});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isAccountCreated ? "Not a member?" : "Already have account?",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: loginRegisterSwitch,
          child: Text(
            isAccountCreated ? "Create account now" : "Sign In now",
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
