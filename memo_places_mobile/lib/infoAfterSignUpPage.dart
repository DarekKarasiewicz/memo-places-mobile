import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/signInOrSignUpPage.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

class InfoAfterSignUpPage extends StatelessWidget {
  const InfoAfterSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Logo",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    LocaleKeys.link_to_active_info.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SignInSignUpButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInOrSingUpPage(),
                          ),
                        );
                      },
                      buttonText: LocaleKeys.back.tr()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
