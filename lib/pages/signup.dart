// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/pages/user.dart';
import 'package:vpass/pages/home.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vpass/services/user_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController txtUsername = TextEditingController(text: 'driver0');
  TextEditingController txtPassword = TextEditingController(text: '1234');
  TextEditingController txtFirstname = TextEditingController(text: 'John');
  TextEditingController txtMiddlename = TextEditingController(text: 'Doe');
  TextEditingController txtLastname = TextEditingController(text: 'Doe');
  String? txtType = 'driver';
  DateTime? txtBirthday;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    initAll();
  }

  void initAll() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void signUp() async {
    final response = await UserService.signUp(
      txtUsername.text,
      txtPassword.text,
      txtFirstname.text,
      txtMiddlename.text,
      txtLastname.text,
      txtType,
      DateFormat('yyyy-MM-dd').format(txtBirthday!),
    );
    switch (response.statusCode) {
      case 200:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Notice'),
              content: Text('Account created!'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context, 'OK');
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                )
              ],
            );
          },
        );
        break;
      case 500:
      default:
        List<Widget> content = [];
        Map responseErrors = jsonDecode(response.body)['errors'];
        responseErrors.forEach(
          (field, errors) {
            for (final error in errors) {
              content.add(
                SizedBox(
                  height: 5,
                ),
              );
              content.add(Text(error));
            }
          },
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Column(
                children: content,
                mainAxisSize: MainAxisSize.min,
              ),
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
      appBar: LoggedInAppBar(page: 'SignUp'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Username',
                ),
                textAlign: TextAlign.center,
                controller: txtUsername,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                textAlign: TextAlign.center,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: txtPassword,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Firstname',
                ),
                textAlign: TextAlign.center,
                controller: txtFirstname,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Middlename',
                ),
                textAlign: TextAlign.center,
                controller: txtMiddlename,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Lastname',
                ),
                textAlign: TextAlign.center,
                controller: txtLastname,
              ),
              TextButton(
                child: Text(txtBirthday != null
                    ? DateFormat('MMMM dd, yyyy').format(txtBirthday!)
                    : 'Select birthday'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      lastDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      initialDate: DateTime.now());
                  if (picked != null && picked != txtBirthday) {
                    setState(() {
                      txtBirthday = picked;
                    });
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  signUp();
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
