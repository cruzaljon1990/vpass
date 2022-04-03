import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/pages/log.dart';
import 'package:vpass/pages/log_view.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/services/log_service.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class AddLogView extends StatefulWidget {
  AddLogView({Key? key}) : super(key: key);

  @override
  State<AddLogView> createState() => _LogViewState();
}

class _LogViewState extends State<AddLogView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtFirstname = TextEditingController();
  TextEditingController txtMiddlename = TextEditingController();
  TextEditingController txtLastname = TextEditingController();
  TextEditingController txtModel = TextEditingController();
  TextEditingController txtPlateNo = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void resetTextControllers() {
    txtFirstname.text = '';
    txtMiddlename.text = '';
    txtLastname.text = '';
    txtModel.text = '';
    txtPlateNo.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: LoggedInAppBar(page: 'AddLogView'),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 13,
                          right: 10,
                        ),
                        child: Text(
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
                        padding: EdgeInsets.only(
                          top: 13,
                          right: 10,
                        ),
                        child: Text(
                          'Middlename:',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(controller: txtMiddlename),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 13,
                          right: 10,
                        ),
                        child: Text(
                          'Lastname:',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(controller: txtLastname),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 13,
                          right: 10,
                        ),
                        child: Text(
                          'Model:',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(controller: txtModel),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 13,
                          right: 10,
                        ),
                        child: Text(
                          'Plate No.:',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(controller: txtPlateNo),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  var logData = {
                    'firstname': txtFirstname.text,
                    'middlename': txtMiddlename.text,
                    'lastname': txtLastname.text,
                    'plate_no': txtPlateNo.text,
                    'model': txtModel.text,
                  };
                  var logUpdateResponse = await LogService.create(logData);
                  if (logUpdateResponse['statusCode'] == 200) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Message'),
                          content: const Text('Log added!'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                resetTextControllers();
                                Navigator.of(context).pop('OK');
                                Navigator.of(context).pushReplacement(
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: LogView(
                                      id: logUpdateResponse['data'].id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else if (logUpdateResponse['statusCode'] == 401) {
                    Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const Login(),
                        ),
                        (route) => false);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add Log'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
