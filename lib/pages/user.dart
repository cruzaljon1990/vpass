// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/pages/home.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/pages/user_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/user_service.dart';

class UserPage extends StatefulWidget {
  String? type = 'driver';
  UserPage({Key? key, this.type}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  var users;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PopupMenuItem> popUpMenuItem = [
      PopupMenuItem(
        value: 1,
        child: Text('View'),
      ),
    ];

    if (SharedPreferencesService.getString('session_user_type') == 'admin') {
      popUpMenuItem.add(PopupMenuItem(
        value: 2,
        child: Text('Edit'),
      ));
      popUpMenuItem.add(PopupMenuItem(
        value: 3,
        child: Text('Delete'),
      ));
    }
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.type == 'driver'
                ? 'Drivers'
                : (widget.type == 'guard' ? 'Guards' : 'Admins'),
          ),
        ),
        body: Center(
          child: FutureBuilder(
            future: UserService.getUsers(widget.type),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var statusCode = snapshot.data['statusCode'];
                if (statusCode == 200) {
                  var users = snapshot.data['data'];
                  return ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () async {
                          await showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                                25, (index + 1) * 120, 20, 0),
                            items: popUpMenuItem,
                            elevation: 8.0,
                          ).then((value) async {
                            switch (value) {
                              case 1:
                                await viewUser(users[index].id);
                                break;
                              case 3:
                                showDialog(
                                    context: context,
                                    builder: (builder) {
                                      return AlertDialog(
                                        title: Text('Notice'),
                                        content: Text(
                                            'Are you sure you want to delete ${users[index].username}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'Cancel');
                                            },
                                            child: Text(
                                              'Cancel',
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              UserService.delete(
                                                  users[index].id);
                                              setState(() {});
                                              Navigator.pop(context, 'YES');
                                            },
                                            child: Text(
                                              'YES',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                                break;
                              default:
                            }
                          });
                        },
                        onTap: () async {
                          await viewUser(users[index].id);
                        },
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 0, bottom: 0, left: 15, right: 0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              trailing: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(
                                  widget.type == 'driver'
                                      ? Icons.drive_eta
                                      : (widget.type == 'guard'
                                          ? Icons.security
                                          : Icons.people),
                                  color: widget.type == 'driver'
                                      ? (users[index].hasVehiclesInside
                                          ? Colors.green
                                          : Colors.red)
                                      : Colors.grey[900],
                                ),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${users[index].username}: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            '${users[index].firstname} ${users[index].lastname}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (statusCode == 401) {
                  SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
                    Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const Login(),
                        ),
                        (route) => false);
                  });
                } else {
                  SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
                    Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const Home(),
                        ),
                        (route) => false);
                  });
                }
                return Text('waiting...');
              } else {
                return Text('waiting...');
              }

              // if (snapshot.connectionState != ConnectionState.done) {
              //   return Center(
              //     child: Text('waiting...'),
              //   );
              // } else {
              //
              // }
            },
          ),
        ),
      ),
    );
  }

  viewUser(id) async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: UserView(id: id),
      ),
    );
  }
}
