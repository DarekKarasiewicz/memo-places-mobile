import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

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
              ? LocaleKeys.not_member.tr()
              : LocaleKeys.question_account.tr(),
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: loginRegisterSwitch,
          child: Text(
            isAccountCreated
                ? LocaleKeys.create_account.tr()
                : LocaleKeys.sign_account.tr(),
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
