import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/models/VehicleModel.dart';
import 'package:vpass/pages/user_view.dart';
import 'package:vpass/pages/vehicle_view.dart';
import 'package:vpass/services/shared_preferences_service.dart';
import 'package:vpass/services/user_service.dart';
import 'package:vpass/services/vehicle_service.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({Key? key}) : super(key: key);

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }

    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: LoggedInAppBar(page: 'QRCodeScanner'),
          body: Stack(
            alignment: Alignment.center,
            children: [
              buildQrView(context),
              const Positioned(
                child: Text(
                  'Scan the QR Code',
                  maxLines: 3,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                bottom: 20,
              ),
            ],
          ),
        ),
      );

  viewVehicle(vehicle) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: VehicleView(
          id: vehicle.id.toString(),
        ),
      ),
    );
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          bool gotValidQR = false;
          setState(() {
            this.controller = controller;
          });

          // Scanned a barcode
          controller.scannedDataStream.listen((barcode) async {
            controller.pauseCamera();
            List<String> splittedBarcode = barcode.code.toString().split('|');
            String log_id = '';
            String vehicle_id = splittedBarcode[0];
            VehicleModel vehicle;
            if (splittedBarcode.length == 2) {
              vehicle_id = splittedBarcode[0];
              log_id = splittedBarcode[1];
            } else {
              vehicle_id = barcode.code.toString();
            }

            var getVehicleResponse =
                await VehicleService.getVehicle(vehicle_id);

            if (getVehicleResponse['statusCode'] == 200) {
              vehicle = getVehicleResponse['data'];

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Vehicle'),
                    content: Text(
                      'Vehicle: ${vehicle.model} [${vehicle.plate_no.toUpperCase()}]',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'Cancel');
                          controller.resumeCamera();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context, 'OK');
                          var toggleVehicleResponse =
                              await VehicleService.toggleStatus(
                                  vehicle.id.toString());
                          if (toggleVehicleResponse['statusCode'] == 200) {
                            viewVehicle(toggleVehicleResponse['data']);
                          } else if (toggleVehicleResponse['statusCode'] ==
                              501) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Notice'),
                                  content: const Text(
                                    'Log creation failed! Parking slots are full!',
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, 'OK');
                                          controller.resumeCamera();
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Notice'),
                                  content: const Text('Invalid QR!'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, 'OK');
                                          controller.resumeCamera();
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
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Notice'),
                    content: const Text('Invalid QR!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'OK');
                          controller.resumeCamera();
                        },
                        child: const Text('OK'),
                      )
                    ],
                  );
                },
              );
            }
          });
        },
        overlay: QrScannerOverlayShape(
          borderLength: 20,
          borderWidth: 10,
          borderColor: CustomColors.orange,
          borderRadius: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );
}
