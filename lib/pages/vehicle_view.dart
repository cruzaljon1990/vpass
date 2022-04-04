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
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/models/VehicleModel.dart';
import 'package:vpass/pages/log_view.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/services/log_service.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/vehicle_service.dart';

class VehicleView extends StatefulWidget {
  String id;
  VehicleView({Key? key, required this.id}) : super(key: key);

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final qrKey = GlobalKey();
  String qrData = '';
  VehicleModel? vehicle = null;

  @override
  void initState() {
    // TODO: implement initState
    refreshVehicle(widget.id);
    super.initState();
    qrData = '';
  }

  viewLog(id) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: LogView(id: id),
      ),
    );
  }

  getQrData(VehicleModel vehicle) {
    String qrString = vehicle.id.toString();
    if (vehicle.logs!.isNotEmpty) {
      for (var i = 0; i < vehicle.logs!.length; i++) {
        LogModel log = LogModel.fromJson(vehicle.logs![i]);
        if (vehicle.is_in == true && log.time_out == null) {
          qrString += '|' + log.id.toString();
          break;
        }
      }
    }
    return qrString;
  }

  void refreshVehicle(id) async {
    var response = await VehicleService.getVehicle(id.toString());

    if (response['statusCode'] == 200) {
      setState(() {
        vehicle = response['data'];
        if (SharedPreferencesService.getString('session_user_type') !=
            'driver') {
          qrData = getQrData(vehicle!);
        }
      });
    } else if (response['statusCode'] == 401) {
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
    QrImage qrImage = QrImage(
      data: qrData,
      size: 300,
      backgroundColor: Colors.white,
    );

    if (vehicle != null) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: LoggedInAppBar(page: 'VehicleView'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(children: [
              Center(
                  child: qrData == ''
                      ? ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Health Declaration'),
                                  content: const Text(
                                      'By selecting agree, you are confirming that you have not been sick and have not been in contact with any sick person in the last 7 days.'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Decline'),
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                    ),
                                    TextButton(
                                      child: const Text('Agree'),
                                      onPressed: () {
                                        setState(() {
                                          qrData = getQrData(vehicle!);
                                        });
                                        Navigator.pop(context, 'OK');
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Generate QR Code'),
                        )
                      : qrImage),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Model: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(vehicle!.model)
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Plate No.: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(vehicle!.plate_no.toUpperCase())
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    vehicle!.is_in == true ? 'IN' : 'OUT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: vehicle!.is_in == true ? Colors.green : Colors.red,
                    ),
                  )
                ],
              ),
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
                'Latest Logs',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: vehicle!.logs!.isNotEmpty
                    ? vehicle!.logs!.map(
                        (_log) {
                          Offset _tapDownPosition = const Offset(0, 0);
                          var log = LogModel.fromJson(_log);
                          return Card(
                            child: GestureDetector(
                              child: ListTile(
                                leading: log.is_vip == true
                                    ? const Icon(
                                        Icons.star,
                                        color: CustomColors.orange,
                                      )
                                    : const Icon(Icons.person),
                                contentPadding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 5, bottom: 5),
                                trailing: Icon(
                                  Icons.drive_eta,
                                  size: 14,
                                  color: log.time_out == null
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: DateFormat('MM/dd/yy hh:mm a')
                                                .format(DateTime.parse(
                                                    log.time_in.toString())) +
                                            '\n',
                                        style: TextStyle(
                                          color: Colors.grey[900],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${log.model!.toUpperCase()} [${log.plate_no!.toUpperCase()}]',
                                        style:
                                            TextStyle(color: Colors.grey[900]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () async {
                                await viewLog(log.id);
                              },
                              onTapDown: (TapDownDetails details) {
                                _tapDownPosition = details.globalPosition;
                              },
                              onLongPress: () async {
                                List<PopupMenuItem> popUpMenuItem = const [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text('View'),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Text('Delete'),
                                  ),
                                ];
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
                                      await viewLog(log.id);
                                      break;
                                    case 2:
                                      showDialog(
                                          context: context,
                                          builder: (builder) {
                                            return AlertDialog(
                                              title: const Text('Notice'),
                                              content: Text(
                                                  'Are you sure you want to delete log of ${log.firstname} ${log.lastname} (${log.model} - ${log.plate_no.toString().toUpperCase()})?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, 'Cancel');
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    var logDeleteResponse =
                                                        await LogService.delete(
                                                            log.id);
                                                    if (logDeleteResponse[
                                                            'statusCode'] ==
                                                        200) {
                                                      refreshVehicle(vehicle!.id
                                                          .toString());
                                                      Navigator.pop(
                                                          context, 'YES');
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Notice'),
                                                            content: const Text(
                                                              'Log deleted!',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      dialogContext,
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
                                                            title: const Text(
                                                                'Notice'),
                                                            content: const Text(
                                                              'Failed to delete log!',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      dialogContext,
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
                                                  child: const Text(
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
                            ),
                          );
                        },
                      ).toList()
                    : [const Text('No logs yet.')],
              ),
              const SizedBox(
                height: 10,
              ),
              (() {
                if (vehicle!.is_in == false &&
                    SharedPreferencesService.getString('session_user_type') !=
                        'driver') {
                  return ElevatedButton(
                      onPressed: () async {
                        if (vehicle != null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Vehicle'),
                                content: Text(
                                  'Vehicle: ${vehicle!.model} [${vehicle!.plate_no.toUpperCase()}]',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Cancel');
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context, 'OK');
                                      var toggleVehicleResponse =
                                          await VehicleService.toggleStatus(
                                              vehicle!.id.toString());
                                      if (toggleVehicleResponse['statusCode'] ==
                                          200) {
                                        refreshVehicle(vehicle!.id);
                                      } else if (toggleVehicleResponse[
                                              'statusCode'] ==
                                          501) {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title: const Text('Notice'),
                                              content: const Text(
                                                'Log creation failed! Parking slots are full!',
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          dialogContext, 'OK');
                                                    },
                                                    child: const Text('OK'))
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title: const Text('Notice'),
                                              content:
                                                  const Text('Invalid QR!'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          dialogContext, 'OK');
                                                    },
                                                    child: const Text('OK'))
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text('Add Log'));
                } else {
                  return const SizedBox.shrink();
                }
              })()
            ]),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: LoggedInAppBar(page: 'VehicleView'),
        body: const Center(
          child: Text('waiting...'),
        ),
      );
    }
  }
}
