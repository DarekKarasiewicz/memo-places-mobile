import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:memo_places_mobile/signInOrSignUpPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoAfterSignUpPage extends StatelessWidget {
  const InfoAfterSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
        ),
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
                      AppLocalizations.of(context)!.linkToActiveInfo,
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
                        buttonText: AppLocalizations.of(context)!.back),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
