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

class User extends StatefulWidget {
  String? type = 'driver';
  User({Key? key, this.type}) : super(key: key);

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtName = TextEditingController(text: '');
  var users;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        child: Text('Delete'),
      ));
    }
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            widget.type == 'driver'
                ? 'Drivers'
                : (widget.type == 'guard' ? 'Guards' : 'Admins'),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Search:'),
                      content: TextField(
                        onChanged: (value) {},
                        controller: txtName,
                        decoration: const InputDecoration(
                            hintText: "Enter name to search"),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            'Cancel',
                          ),
                          onPressed: () {
                            Navigator.of(context).pop('Cancel');
                          },
                        ),
                        TextButton(
                          child: const Icon(
                            Icons.search,
                          ),
                          onPressed: () {
                            setState(() {});
                            if (txtName.text != '') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 3),
                                  content: Text('Results for: ' + txtName.text),
                                ),
                              );
                            }
                            Navigator.of(context).pop('Cancel');
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        body: Center(
          child: FutureBuilder(
            future: UserService.getUsers(type: widget.type, name: txtName.text),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data['statusCode'] == 200) {
                  var users = snapshot.data['data'];
                  if (users.length > 0) {
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
                                case 2:
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
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              },
                                              child: Text(
                                                'Cancel',
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                var userDeleteResponse =
                                                    await UserService.delete(
                                                        users[index].id);
                                                if (userDeleteResponse[
                                                        'statusCode'] ==
                                                    200) {
                                                  setState(() {});
                                                  Navigator.pop(context, 'YES');
                                                  showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return AlertDialog(
                                                        title: Text('Notice'),
                                                        content: Text(
                                                            'User deleted!'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      dialogContext)
                                                                  .pop('OK');
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return AlertDialog(
                                                        title: Text('Notice'),
                                                        content: Text(
                                                            'Failed to delete user!'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      dialogContext)
                                                                  .pop('OK');
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'YES',
                                                style: TextStyle(
                                                    color: Colors.red),
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
                  } else {
                    return Center(
                      child: Text('No data...'),
                    );
                  }
                } else if (snapshot.data['statusCode'] == 401) {
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
                return Text('No');
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
}
