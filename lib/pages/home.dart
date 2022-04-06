// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
  Timer? intervals;
  var inactive_users_count = 0;

  getAdminNotifs() async {
    if (SharedPreferencesService.getString('session_user_type') == 'admin') {
      var getAdminNotifsResponse = await http.get(
        Uri.parse(dotenv.get('API_URL') + 'user/get-admin-notifs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ' + SharedPreferencesService.getString('session_token')
        },
      );
      setState(() {
        inactive_users_count =
            jsonDecode(getAdminNotifsResponse.body)['inactive_users_count'];
      });
    }
  }

  @override
  void initState() {
    intervals = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await getAdminNotifs();
    });
    super.initState();
  }

  @override
  void dispose() {
    if (intervals != null) {
      intervals!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> gridViewItems = [
      Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Icon(
                    Icons.qr_code,
                    size: 50,
                  ),
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
            Positioned(
              bottom: 15,
              child: Text(
                'QR Scanner',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
      Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Icon(
                    Icons.format_list_bulleted,
                    size: 50,
                  ),
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
            Positioned(
              bottom: 15,
              child: Text(
                'Logs',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
      Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Icon(
                    Icons.drive_eta,
                    size: 50,
                  ),
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
            Positioned(
              bottom: 15,
              child: Text(
                'Drivers',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    ];
    if (SharedPreferencesService.getString('session_user_type') == 'admin') {
      if (SharedPreferencesService.getBool('session_user_is_super') == true) {
        gridViewItems.add(
          Center(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 50,
                      ),
                    ),
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                          content: Text('Admins'),
                        ),
                      );
                    },
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: User(status: 1, type: 'admin'),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 15,
                  child: Text(
                    'Admins',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      gridViewItems.add(
        Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(
                      Icons.security,
                      size: 50,
                    ),
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
                          status: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 15,
                child: Text(
                  'Guards',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      );

      gridViewItems.add(
        Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(
                      Icons.block,
                      size: 50,
                    ),
                  ),
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                        content: Text('Inactives'),
                      ),
                    );
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: User(
                          status: 0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 15,
                child: Text(
                  'Inactives',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
              if (inactive_users_count > 0) ...[
                Positioned(
                  right: 20,
                  top: 20,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      inactive_users_count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

      gridViewItems.add(
        Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(
                      Icons.settings,
                      size: 50,
                    ),
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
              Positioned(
                bottom: 15,
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: LoggedInAppBar(
        page: 'Home',
      ),
      body: GridView.count(
        childAspectRatio: 6 / 5,
        crossAxisCount: 2,
        children: gridViewItems,
      ),
    );
  }
}
