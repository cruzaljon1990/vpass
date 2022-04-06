// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/pages/home.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/pages/user_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/user_service.dart';

class User extends StatefulWidget {
  String? type = 'driver';
  int? status;
  User({Key? key, this.type, this.status}) : super(key: key);

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController txtName = TextEditingController(text: '');
  bool initLoading = false, loading = false, allLoaded = false;
  var users = [], page = 1;

  @override
  void initState() {
    super.initState();
    widget.status = widget.status ?? 1;
    initLoading = true;
    loadUsers(page: page);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        loadUsers(page: ++page);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void resetUsers() {
    setState(() {
      allLoaded = false;
      initLoading = true;
      users = [];
    });
    page = 1;
    loadUsers(page: page);
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

  void loadUsers({int page = 1}) async {
    if (allLoaded) {
      return;
    }
    setState(() {
      loading = true;
    });
    var getUsersResponse = await UserService.getUsers(
      type: widget.type,
      name: txtName.text,
      page: page,
      status: widget.status,
    );
    if (getUsersResponse['statusCode'] == 200) {
      if (getUsersResponse['data'].isNotEmpty) {
        users.addAll(getUsersResponse['data']);
      }
      setState(() {
        initLoading = false;
        loading = false;
        allLoaded = getUsersResponse['data'].isEmpty;
      });
    } else if (getUsersResponse['statusCode'] == 401) {
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
        resetUsers();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.type == 'driver'
                ? 'Drivers'
                : (widget.type == 'guard' ? 'Guards' : 'Inactives'),
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
                            if (txtName.text != '') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 3),
                                  content: Text('Results for: ' + txtName.text),
                                ),
                              );
                            }
                            Navigator.of(context).pop('OK');
                            setState(() {
                              allLoaded = false;
                              initLoading = true;
                              users = [];
                            });
                            page = 1;
                            loadUsers(page: page);
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (!initLoading) {
              if (users.isNotEmpty) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index < users.length) {
                            Offset _tapDownPosition = const Offset(0, 0);
                            return GestureDetector(
                              onTapDown: (TapDownDetails details) {
                                _tapDownPosition = details.globalPosition;
                              },
                              onLongPress: () async {
                                await showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    _tapDownPosition.dx,
                                    _tapDownPosition.dy,
                                    MediaQuery.of(context).size.width -
                                        _tapDownPosition.dx,
                                    MediaQuery.of(context).size.height -
                                        _tapDownPosition.dy,
                                  ),
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
                                                        await UserService
                                                            .delete(users[index]
                                                                .id);
                                                    if (userDeleteResponse[
                                                            'statusCode'] ==
                                                        200) {
                                                      Navigator.pop(
                                                          context, 'YES');
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return AlertDialog(
                                                            title:
                                                                Text('Notice'),
                                                            content: Text(
                                                                'User deleted!'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  resetUsers();
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop(
                                                                          'OK');
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'OK'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return AlertDialog(
                                                            title:
                                                                Text('Notice'),
                                                            content: Text(
                                                                'Failed to delete user!'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop(
                                                                          'OK');
                                                                },
                                                                child:
                                                                    const Text(
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
                                child: ListTile(
                                  leading: (users[index].status == 1
                                      ? users[index].is_vip == true
                                          ? const Icon(
                                              Icons.star,
                                              color: CustomColors.orange,
                                            )
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.blue,
                                            )
                                      : Icon(
                                          Icons.block,
                                          color: Colors.grey,
                                        )),
                                  contentPadding: EdgeInsets.only(
                                      top: 0, bottom: 0, left: 10, right: 0),
                                  trailing: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(
                                      users[index].type == 'driver'
                                          ? Icons.drive_eta
                                          : (users[index].type == 'guard'
                                              ? Icons.security
                                              : Icons.people),
                                      color: users[index].status == 1
                                          ? (widget.type == 'driver'
                                              ? users[index].hasVehiclesInside
                                                  ? Colors.green
                                                  : Colors.red
                                              : Colors.grey[900])
                                          : Colors.grey,
                                    ),
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: users[index].status == 1
                                            ? Colors.black
                                            : Colors.grey,
                                        decoration: users[index].status == 1
                                            ? TextDecoration.none
                                            : TextDecoration.lineThrough,
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
                            );
                          } else {
                            return SizedBox(
                              width: constraints.maxWidth,
                              height: 50,
                              child:
                                  Center(child: Text('All users are loaded!')),
                            );
                          }
                        },
                        itemCount: users.length + (allLoaded ? 1 : 0),
                      ),
                      if (loading) ...[
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: 80,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      ],
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No Data'));
              }
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: CustomColors.orange,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
