import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/models/VehicleModel.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class VehicleView extends StatefulWidget {
  VehicleModel vehicle;
  VehicleView({Key? key, required this.vehicle}) : super(key: key);

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  final qrKey = GlobalKey();
  String qrData = '';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    qrData = '';
  }

  @override
  Widget build(BuildContext context) {
    if (SharedPreferencesService.getString('session_user_type') != 'driver') {
      setState(() {
        qrData = getQrData(widget.vehicle);
      });
    }

    QrImage qrImage = QrImage(
      data: qrData,
      size: 300,
      backgroundColor: Colors.white,
    );

    return Scaffold(
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
                                        qrData = getQrData(widget.vehicle);
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
                Text(widget.vehicle.model)
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
                Text(widget.vehicle.plate_no.toUpperCase())
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
                  widget.vehicle.is_in == true ? 'IN' : 'OUT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.vehicle.is_in == true
                        ? Colors.green
                        : Colors.red,
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
              children: widget.vehicle.logs!.map(
                (_log) {
                  var log = LogModel.fromJson(_log);
                  return Card(
                    child: GestureDetector(
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        trailing: Icon(
                          Icons.drive_eta,
                          size: 14,
                          color:
                              log.time_out == null ? Colors.green : Colors.red,
                        ),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: DateFormat('MM/dd/yy hh:mm a').format(
                                        DateTime.parse(
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
                                style: TextStyle(color: Colors.grey[900]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () async {
                        // await viewVehicle(vehicle);
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
          ]),
        ),
      ),
    );
  }
}
