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
import 'package:vpass/pages/login.dart';
import 'package:vpass/pages/vehicle_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/user_service.dart';
import 'package:vpass/services/vehicle_service.dart';

class UserView extends StatefulWidget {
  final String id;
  UserView({Key? key, required this.id}) : super(key: key);

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
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
  int? txtStatus;

  @override
  void initState() {
    // TODO: implement initState
    refreshUser(widget.id);
    super.initState();
  }

  viewVehicle(vehicle) async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: VehicleView(vehicle: vehicle),
      ),
    );
  }

  void refreshUser(id) async {
    var response = await UserService.getUser(id.toString());

    if (response['statusCode'] == 200) {
      setState(() {
        user = response['data'];
      });
      txtFirstname.text = user!.firstname;
      txtMiddlename.text = user!.middlename;
      txtLastname.text = user!.lastname;
      txtBirthday = user!.birthday;
      txtType = user!.type;
      txtStatus = user!.status;
      txtModel.text = '';
      txtPlateNo.text = '';
    } else if (response.statusCode == 401) {
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: const Login(),
          ),
          (route) => false);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
        appBar: LoggedInAppBar(page: 'UserView'),
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
                        TextField(
                          controller: txtFirstname,
                          enabled: SharedPreferencesService.getString(
                                  'session_user_type') ==
                              'admin',
                        )
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
                        TextField(
                          controller: txtMiddlename,
                          enabled: SharedPreferencesService.getString(
                                  'session_user_type') ==
                              'admin',
                        ),
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
                        TextField(
                          controller: txtLastname,
                          enabled: SharedPreferencesService.getString(
                                  'session_user_type') ==
                              'admin',
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(
                              top: 13, right: 5, bottom: 15),
                          child: Text(
                            'Birthday:',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SharedPreferencesService.getString(
                                    'session_user_type') ==
                                'admin'
                            ? SizedBox(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    alignment: Alignment.centerLeft,
                                    primary: Colors.orange,
                                  ),
                                  child: Text(txtBirthday != null
                                      ? DateFormat('MMMM dd, yyyy')
                                          .format(txtBirthday!)
                                      : 'Select birthday'),
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      lastDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      initialDate: DateTime.now(),
                                    );
                                    if (picked != null &&
                                        picked != txtBirthday) {
                                      setState(() {
                                        txtBirthday = picked;
                                      });
                                    }
                                  },
                                ),
                                height: 50,
                                width: 50,
                              )
                            : TextField(
                                controller: TextEditingController(
                                  text: DateFormat('MMMM dd, yyyy')
                                      .format(txtBirthday!),
                                ),
                                enabled: false,
                              ),
                      ],
                    ),
                    (() {
                      if (SharedPreferencesService.getString(
                              'session_user_type') ==
                          'admin') {
                        return TableRow(
                          children: [
                            const Padding(
                              padding: const EdgeInsets.only(top: 13),
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
                        );
                      } else {
                        return const TableRow(
                          children: [SizedBox.shrink(), SizedBox.shrink()],
                        );
                      }
                    })(),
                    (() {
                      if (SharedPreferencesService.getString(
                              'session_user_type') ==
                          'admin') {
                        return TableRow(children: [
                          const Padding(
                            padding: const EdgeInsets.only(top: 15, right: 5),
                            child: Text(
                              'Type:',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: DropdownButton<String>(
                              itemHeight: 55,
                              isExpanded: true,
                              value: txtType,
                              iconSize: 20,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 20,
                              style: TextStyle(
                                color: Colors.grey[900],
                              ),
                              underline: Container(
                                height: 2,
                                color: CustomColors.orange,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  txtType = newValue!;
                                });
                              },
                              items: <String>[
                                'admin',
                                'guard',
                                'driver',
                              ].map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value.toUpperCase(),
                                      textAlign: TextAlign.start,
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ]);
                      } else {
                        return const TableRow(
                          children: [SizedBox.shrink(), SizedBox.shrink()],
                        );
                      }
                    })(),
                    TableRow(children: [
                      const Padding(
                        padding: const EdgeInsets.only(
                            top: 15, right: 5, bottom: 10),
                        child: Text(
                          'Status:',
                          textAlign: TextAlign.end,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: SharedPreferencesService.getString(
                                    'session_user_type') ==
                                'admin'
                            ? DropdownButton<String>(
                                itemHeight: 55,
                                isExpanded: true,
                                value: txtStatus == 1 ? 'active' : 'inactive',
                                iconSize: 20,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 20,
                                style: TextStyle(
                                  color: Colors.grey[900],
                                ),
                                underline: Container(
                                  height: 2,
                                  color: CustomColors.orange,
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue == 'active') {
                                      txtStatus = 1;
                                    } else {
                                      txtStatus = 0;
                                    }
                                  });
                                },
                                items: <String>['active', 'inactive']
                                    .map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value.toUpperCase(),
                                        textAlign: TextAlign.start,
                                      ),
                                    );
                                  },
                                ).toList(),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: Text(
                                  txtStatus == 1 ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: txtStatus == 1
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ),
                      ),
                    ]),
                    TableRow(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(
                              top: 8, right: 5, bottom: 20),
                          child: Text(
                            'Age:',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 5),
                          child: Text(
                            '${user!.age} years old',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SharedPreferencesService.getString('session_user_type') ==
                        'guard'
                    ? const SizedBox.shrink()
                    : ElevatedButton(
                        onPressed: () async {
                          var userData = {
                            'firstname': txtFirstname.text,
                            'middlename': txtMiddlename.text,
                            'lastname': txtLastname.text,
                            'birthday':
                                DateFormat('yyyy-MM-dd').format(txtBirthday!),
                            'type': txtType,
                            'status': txtStatus
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
                                  content: const Text('User is updated!'),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
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
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
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
                                    contentPadding:
                                        EdgeInsets.only(right: 20, left: 20),
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
                                  onLongPress: () {
                                    print('long pressed');
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

                            if (response.statusCode == 200) {
                              refreshUser(user!.id);
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
