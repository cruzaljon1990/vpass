import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/pages/log.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/services/log_service.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class LogView extends StatefulWidget {
  String? id;
  LogView({Key? key, required this.id}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  LogModel? log = null;
  TextEditingController txtFirstname = TextEditingController();
  TextEditingController txtMiddlename = TextEditingController();
  TextEditingController txtTimeIn = TextEditingController();
  TextEditingController txtTimeOut = TextEditingController();
  TextEditingController txtLastname = TextEditingController();
  TextEditingController txtModel = TextEditingController();
  TextEditingController txtPlateNo = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    refreshLog(widget.id);
    super.initState();
  }

  void refreshLog(String? id) async {
    var response = await LogService.getLog(id.toString());

    if (response['statusCode'] == 200) {
      setState(() {
        log = response['data'];
      });
      if (log != null) {
        print(log);
        txtFirstname.text = log!.firstname!;
        txtMiddlename.text = log!.middlename!;
        txtLastname.text = log!.lastname!;

        txtModel.text = log!.model!;
        txtPlateNo.text = log!.plate_no!;
        txtTimeIn.text =
            DateFormat('MMMM dd, yyyy hh:mm').format(log!.time_in!);
        if (log!.time_out != null) {
          txtTimeOut.text =
              DateFormat('MMMM dd, yyyy hh:mm').format(log!.time_out!);
        }
      }
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
    if (log != null) {
      showToggleMenu() {
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                title: const Text('Notice'),
                content: Text(
                    'Are you sure you want to update the log status of ${log!.model} - ${log!.plate_no.toString().toUpperCase()}?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var logDeleteResponse =
                          await LogService.toggleStatus(log!.id.toString());
                      if (logDeleteResponse['statusCode'] == 200) {
                        refreshLog(log!.id.toString());
                        Navigator.pop(context, 'YES');
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Notice'),
                              content:
                                  const Text('Vehicle log status updated!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, 'OK');
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (logDeleteResponse['statusCode'] == 401) {
                        Navigator.of(context).pushAndRemoveUntil(
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: const Login(),
                            ),
                            (route) => false);
                      } else {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Notice'),
                              content: const Text(
                                  'Failed to update vehicle status!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, 'OK');
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      'YES',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            });
      }

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
                            'Time In:',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextField(
                          enabled: false,
                          controller: txtTimeIn,
                        ),
                      ],
                    ),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 13,
                          right: 10,
                        ),
                        child: Text(
                          'Time Out:',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      (() {
                        if (log!.time_out != null) {
                          return TextField(
                            enabled: false,
                            controller: txtTimeIn,
                          );
                        } else {
                          Offset _tapDownPosition = const Offset(0, 0);
                          return GestureDetector(
                            child: TextField(
                              enabled: false,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                              controller:
                                  TextEditingController(text: 'STILL INSIDE'),
                            ),
                            onTapDown: (TapDownDetails details) {
                              _tapDownPosition = details.globalPosition;
                            },
                            onDoubleTap: showToggleMenu,
                            onLongPress: () async {
                              List<PopupMenuItem> popUpMenuItem = const [
                                PopupMenuItem(
                                  value: 1,
                                  child: Text('Update Log Status'),
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
                                    showToggleMenu();
                                    break;
                                  default:
                                }
                              });
                            },
                          );
                        }
                      })(),
                    ]),
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
                        TextField(
                            controller: txtFirstname,
                            enabled: log!.time_out == null),
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
                        TextField(
                            controller: txtMiddlename,
                            enabled: log!.time_out == null),
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
                        TextField(
                            controller: txtLastname,
                            enabled: log!.time_out == null),
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
                        TextField(
                          controller: txtModel,
                          enabled: log!.time_out == null,
                        ),
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
                        TextField(
                          controller: txtPlateNo,
                          enabled: log!.time_out == null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                (() {
                  if (log!.time_out == null) {
                    return ElevatedButton(
                      onPressed: showToggleMenu,
                      child: const Text(
                        'Update Log Status',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey[300],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                })(),
                (() {
                  if (log!.time_out == null) {
                    return ElevatedButton(
                      onPressed: () async {
                        var logData = {
                          'firstname': txtFirstname.text,
                          'middlename': txtMiddlename.text,
                          'lastname': txtLastname.text,
                          'plate_no': txtPlateNo.text,
                          'model': txtModel.text,
                        };
                        var logUpdateResponse = await LogService.update(
                          log!.id.toString(),
                          logData,
                        );
                        if (logUpdateResponse['statusCode'] == 200) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Message'),
                                content: const Text('Log updated!'),
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
                      child: const Text('Update Log'),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                })(),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (builder) {
                        return AlertDialog(
                          title: const Text('Notice'),
                          content: Text(
                              'Are you sure you want to delete log of ${log!.firstname} ${log!.lastname} (${log!.model} - ${log!.plate_no.toString().toUpperCase()})?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'Cancel');
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                var logUpdateResponse =
                                    await LogService.delete(log!.id.toString());
                                if (logUpdateResponse['statusCode'] == 200) {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Message'),
                                        content: const Text('Log deleted!'),
                                        actions: [
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child: Log(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else if (logUpdateResponse['statusCode'] ==
                                    401) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: const Login(),
                                      ),
                                      (route) => false);
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Delete Log'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: LoggedInAppBar(page: 'LogView'),
        body: const Center(child: Text('Waiting...')),
      );
    }
  }
}
