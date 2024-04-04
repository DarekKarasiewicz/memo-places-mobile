import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    String token ="None";

    Future<void> _login() async {
      String url = 'http://10.0.2.2:8000/memo_places/token/'; // Replace this with your endpoint URL
      String email = emailController.text;
      String password = passwordController.text;

      try {
        var response = await http.post(
          Uri.parse(url),
          body: jsonEncode({'email': email, 'password': password}),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Handle successful response
          print(response.body)
        } else {
          // Handle error response
          print('Failed to login. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle network errors
        print('Error: $e');
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: const Text("Login"),
        ),
        body: Column(
          children: [
            Text("Login"),
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String value) {},
                  ),
                  TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String value) {},
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  Text(
                    //Here should be access token but for now it's none
                    token,
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

