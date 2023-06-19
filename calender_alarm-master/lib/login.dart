import 'dart:convert';
import 'package:calender_alarm/root_page.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:calender_alarm/register_page.dart';
import 'package:http/http.dart' as http; // Import the http package

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

int id = 0;

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void navigateToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void navigateToRootPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RootPage()),
    );
  }

  void login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    // Make an HTTP POST request to the login API endpoint
    final response = await http.put(Uri.parse(
        'http://10.0.2.2/GetUserId.php?user=' +
            email +
            "&pass=" +
            hashedPassword));
    print(response.request);

    if (response.statusCode == 200) {
      // API request successful
      print(response.body); // Debugging purpose (you can remove this line
      final responseBody = json.decode(response.body);

      final bool isUserFound = responseBody['isUserFound'];
      final int userId = responseBody['userId'];
      final String test_id = userId.toString();
      id = userId;

      if (isUserFound) {
        // User found, perform the necessary actions (e.g., navigate to the root page)
        navigateToRootPage();
        saveLoginStatus(true, test_id);
      } else {
        // User not found, show an error message or handle unsuccessful login
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid email or password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // API request failed, show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to connect to the server.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void saveLoginStatus(bool isLoggedIn, String userId) async {
    // Save the login status and user ID using a suitable method
    // For example, you can use shared_preferences package like before
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  'Login Page',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20.0),
            RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  color: Color.fromARGB(255, 199, 199, 199),
                  fontSize: 14.0,
                ),
                children: [
                  TextSpan(
                    text: "Register",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = navigateToRegisterPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
