// ignore_for_file: unnecessary_const

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spannable_grid/spannable_grid.dart';
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/models/VehicleModel.dart';
import 'package:vpass/pages/home.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/pages/vehicle_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/user_service.dart';
import 'package:vpass/services/vehicle_service.dart';

class ProfileView extends StatefulWidget {
  ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserModel? user;
  final qrKey = GlobalKey();
  TextEditingController txtFirstname = TextEditingController();
  TextEditingController txtMiddlename = TextEditingController();
  TextEditingController txtLastname = TextEditingController();
  TextEditingController txtModel = TextEditingController();
  TextEditingController txtPlateNo = TextEditingController();
  DateTime? txtBirthday;
  String? txtType;
  TextEditingController txtPassword = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    refreshUser();
    super.initState();
  }

  viewVehicle(vehicle) async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: VehicleView(
          id: vehicle.id.toString(),
        ),
      ),
    );
  }

  void refreshUser() async {
    var response = await UserService.getProfile();
    if (response['statusCode'] == 200) {
      setState(() {
        user = response['data'];
      });
      txtModel.text = '';
      txtPlateNo.text = '';
      txtFirstname.text = user!.firstname;
      txtMiddlename.text = user!.middlename;
      txtLastname.text = user!.lastname;
      txtBirthday = user!.birthday;
      txtType = user!.type;
    } else if (response['statusCode'] == 401) {
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: const Login(),
          ),
          (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: const Home(),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: LoggedInAppBar(
          page: 'ProfileView',
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 13, right: 5),
                          child: const Text(
                            'Firstname:',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextField(controller: txtFirstname),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(top: 13, right: 5),
                          child: Text(
                            'Middlename:',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextField(controller: txtMiddlename),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(top: 13, right: 5),
                          child: Text(
                            'Lastname:',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextField(controller: txtLastname),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(top: 13, right: 5),
                          child: Text(
                            'Birthday:',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            primary: CustomColors.orange,
                          ),
                          child: Text(txtBirthday != null
                              ? DateFormat('MMMM dd, yyyy').format(txtBirthday!)
                              : 'Select birthday'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              lastDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              initialDate: DateTime.now(),
                            );
                            if (picked != null && picked != txtBirthday) {
                              setState(() {
                                txtBirthday = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(top: 13, right: 5),
                          child: Text(
                            'Password:',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextField(
                          controller: txtPassword,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                      ],
                    ),
                    TableRow(children: [
                      const Padding(
                        padding: const EdgeInsets.only(top: 20, right: 5),
                        child: Text(
                          'Type:',
                          textAlign: TextAlign.end,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20, right: 5, bottom: 10),
                          child: Text(user!.type.toUpperCase()),
                        ),
                      ),
                    ]),
                    TableRow(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(top: 13, right: 5),
                          child: Text(
                            'Age:',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 13, right: 5, bottom: 20),
                          child: Text(
                            '${user!.age} years old',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    var userData = {
                      'firstname': txtFirstname.text,
                      'middlename': txtMiddlename.text,
                      'lastname': txtLastname.text,
                      'birthday': DateFormat('yyyy-MM-dd').format(txtBirthday!),
                      'type': txtType
                    };

                    if (txtPassword.text.isNotEmpty) {
                      userData['password'] = txtPassword.text;
                    }
                    var response = await UserService.update(
                      user!.id.toString(),
                      userData,
                    );

                    if (response['statusCode'] == 200) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Message'),
                            content: const Text('User updated!'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(context, 'OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (response['statusCode'] == 401) {
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Message'),
                            content: const Text('User update failed!'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(context, 'OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Update Info'),
                ),
                Column(
                  children: (() {
                    if (user!.type == 'driver') {
                      return [
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          color: CustomColors.orange,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Vehicles',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: user!.vehicles!.map(
                            (_vehicle) {
                              var vehicle = VehicleModel.fromJson(_vehicle);
                              return Card(
                                child: GestureDetector(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.only(
                                        right: 20, left: 20),
                                    trailing: Icon(
                                      Icons.drive_eta,
                                      size: 14,
                                      color: vehicle.is_in == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    title: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${vehicle.model} - ',
                                            style: TextStyle(
                                                color: Colors.grey[900]),
                                          ),
                                          TextSpan(
                                            text:
                                                vehicle.plate_no.toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.grey[900],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    await viewVehicle(vehicle);
                                  },
                                  onLongPress: () async {
                                    await VehicleService.delete(vehicle.id);
                                    refreshUser();
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              TextField(
                                controller: txtModel,
                                decoration:
                                    const InputDecoration(hintText: 'Model'),
                              ),
                              TextField(
                                controller: txtPlateNo,
                                decoration: const InputDecoration(
                                    hintText: 'Plate No.'),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var response = await VehicleService.create(
                              user!.id.toString(),
                              txtModel.text,
                              txtPlateNo.text,
                            );

                            if (response['statusCode'] == 200) {
                              refreshUser();
                            }
                          },
                          child: const Text('Add Vehicle'),
                        ),
                      ];
                    } else {
                      return <Widget>[];
                    }
                  })(),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('VPass | Driver Details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) {
                switch (value) {
                  case 'Logout':
                    // logout();
                    break;
                  case 'Settings':
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Logout', 'Settings'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
      );
    }
  }
}
