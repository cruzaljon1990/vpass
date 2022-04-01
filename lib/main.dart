// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vpass/pages/home.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/pages/profile_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'colors.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await SharedPreferencesService.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SharedPreferencesService.getString('session_token') != ''
          ? (SharedPreferencesService.getString('session_user_type') != 'driver'
              ? Home()
              : ProfileView())
          : Login(),
      title: 'Demo',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: CustomColors.orange,
          selectionHandleColor: CustomColors.orange,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: CustomColors.orange,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(240, 40),
            primary: CustomColors.orange,
          ),
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            fontSize: 20,
          ),
          bodyText2: TextStyle(
            fontSize: 20,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.only(top: 5, bottom: 5),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CustomColors.orange, width: 1.5),
          ),
        ),
      ),
    );
  }
}
