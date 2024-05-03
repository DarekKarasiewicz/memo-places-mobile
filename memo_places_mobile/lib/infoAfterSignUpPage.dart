import 'package:flutter/material.dart';
import 'package:memo_places_mobile/SignInAndSignUpWidgets/signInSignUpButton.dart';
import 'package:memo_places_mobile/signInOrSignUpPage.dart';

class InfoAfterSignUpPage extends StatelessWidget {
  const InfoAfterSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                      "You will receive an email with link to activate your account.",
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
                        buttonText: "Go Back"),
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
