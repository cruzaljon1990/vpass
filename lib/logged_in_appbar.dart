import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/pages/profile_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/user_service.dart';

class LoggedInAppBar extends StatefulWidget implements PreferredSizeWidget {
  String? page;
  LoggedInAppBar({Key? key, this.page})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _LoggedInAppBarState createState() => _LoggedInAppBarState();
}

class _LoggedInAppBarState extends State<LoggedInAppBar> {
  void logout() async {
    final response = await UserService.logout();
    Navigator.of(context).pushAndRemoveUntil(
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const Login(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.page == 'Home') {
      return AppBar(
        title: const Text('VPass'),
        leading: IconButton(
          icon: const Icon(Icons.person_rounded),
          onPressed: () {
            Navigator.of(context).push(
              PageTransition(
                type: PageTransitionType.rightToLeftWithFade,
                child: ProfileView(),
              ),
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'Logout':
                  logout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return ['Logout'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      );
    } else if (widget.page == 'QRCodeScanner') {
      return AppBar(
        automaticallyImplyLeading: true,
        title: const Text('QR Scanner'),
      );
    } else if (widget.page == 'SignUp') {
      return AppBar(title: const Text('Sign Up'));
    } else if (widget.page == 'UserView') {
      return AppBar(title: const Text('User Details'));
    } else if (widget.page == 'ProfileView') {
      return AppBar(
        title: const Text('Profile Information'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'Logout':
                  logout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return ['Logout'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      );
    } else if (widget.page == 'VehicleView') {
      return AppBar(title: const Text('Vehicle Information'));
    } else if (widget.page == 'Log') {
      return AppBar(title: const Text('Logs'));
    } else if (widget.page == 'LogView') {
      return AppBar(title: const Text('Log Information'));
    } else if (widget.page == 'AddLogView') {
      return AppBar(title: const Text('Add Visitor Log'));
    } else {
      return AppBar(title: const Text('VPass'));
    }
  }
}
