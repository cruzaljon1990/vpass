// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/pages/inactive.dart';
import 'package:vpass/pages/profile_view.dart';
import 'package:vpass/pages/user.dart';
import 'package:vpass/pages/home.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vpass/pages/signup.dart';
import 'package:vpass/pages/user_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/user_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();

  @override
  void dispose() {
    txtUsername.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  void login() async {
    var response = await UserService.login(txtUsername.text, txtPassword.text);
    switch (response.statusCode) {
      case 200:
        var status = jsonDecode(response.body)['status'];
        var user_id = jsonDecode(response.body)['user_id'];
        if (status != 1) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: Inactive(),
            ),
          );
          return;
        }
        var token = jsonDecode(response.body)['token'];
        var user_type = jsonDecode(response.body)['user_type'];
        SharedPreferencesService.setString('session_token', token);
        SharedPreferencesService.setString('session_user_type', user_type);
        SharedPreferencesService.setInteger('session_user_status', status);
        switch (user_type) {
          case 'admin':
          case 'guard':
            Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.rightToLeftWithFade,
                child: const Home(),
              ),
            );
            break;
          case 'driver':
            Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.rightToLeftWithFade,
                child: ProfileView(),
              ),
            );
            break;
          default:
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Message'),
                  content: Text('No ganap!'),
                );
              },
            );
        }
        break;
      case 500:
      default:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Invalid credentials!'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context, 'OK'),
                )
              ],
            );
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('VPass | Login'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 100),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_1000x1000.png',
                  width: 100,
                  height: 100,
                ),
                Text(
                  'VPass',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 60),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Username',
                    contentPadding: EdgeInsets.all(5),
                  ),
                  textAlign: TextAlign.center,
                  controller: txtUsername,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    contentPadding: EdgeInsets.all(5),
                  ),
                  textAlign: TextAlign.center,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: txtPassword,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    login();
                  },
                  child: Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: const SignUp(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.grey[900]),
                  ),
                  style: ElevatedButton.styleFrom(primary: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
