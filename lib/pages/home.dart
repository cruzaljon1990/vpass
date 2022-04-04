// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/pages/settings.dart';
import 'package:vpass/pages/user.dart';
import 'package:vpass/pages/qr_code_scanner.dart';
import 'package:vpass/pages/log.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    List<Widget> gridViewItems = [
      Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: ElevatedButton(
            child: Icon(
              Icons.qr_code,
              size: 50,
            ),
            onLongPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                  content: Text('QR Code Scanner'),
                ),
              );
            },
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: const QRCodeScanner(),
                ),
              );
            },
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: ElevatedButton(
            child: Icon(
              Icons.format_list_bulleted,
              size: 50,
            ),
            onLongPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                  content: Text('Logs'),
                ),
              );
            },
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: Log(),
                ),
              );
            },
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: ElevatedButton(
            child: Icon(
              Icons.drive_eta,
              size: 50,
            ),
            onLongPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                  content: Text('Drivers'),
                ),
              );
            },
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: User(
                    type: 'driver',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
    if (SharedPreferencesService.getString('session_user_type') == 'admin') {
      gridViewItems.add(
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: ElevatedButton(
              child: Icon(
                Icons.security,
                size: 50,
              ),
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                    content: Text('Guards'),
                  ),
                );
              },
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: User(
                      type: 'guard',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      gridViewItems.add(
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: ElevatedButton(
              child: Icon(
                Icons.settings,
                size: 50,
              ),
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                    content: Text('Settings'),
                  ),
                );
              },
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: Settings(),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: LoggedInAppBar(
        page: 'Home',
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: gridViewItems,
      ),
    );
  }
}
