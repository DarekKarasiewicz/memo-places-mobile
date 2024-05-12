import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          isAccountCreated
              ? AppLocalizations.of(context)!.notMember
              : AppLocalizations.of(context)!.questionAccount,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: loginRegisterSwitch,
          child: Text(
            isAccountCreated
                ? AppLocalizations.of(context)!.createAccount
                : AppLocalizations.of(context)!.signAccount,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
