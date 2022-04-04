import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vpass/colors.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/pages/add_log_view.dart';
import 'package:vpass/pages/home.dart';
import 'package:vpass/pages/log_view.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/services/log_service.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class Log extends StatefulWidget {
  const Log({Key? key}) : super(key: key);

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  var logs;
  int? isVisitor;
  TextEditingController txtName = TextEditingController(text: '');

  viewLog(id) async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: LogView(id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    List<PopupMenuItem> popUpMenuItem = [
      const PopupMenuItem(
        value: 1,
        child: Text('View'),
      ),
    ];

    if (SharedPreferencesService.getString('session_user_type') == 'admin') {
      popUpMenuItem.add(const PopupMenuItem(
        value: 2,
        child: Text('Edit'),
      ));
      popUpMenuItem.add(const PopupMenuItem(
        value: 3,
        child: Text('Delete'),
      ));
    }
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: LoggedInAppBar(
          page: 'Log',
          callback: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Search:'),
                  content: TextField(
                    onChanged: (value) {},
                    controller: txtName,
                    decoration:
                        const InputDecoration(hintText: "Enter name to search"),
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        'Cancel',
                        // style: TextStyle(
                        //   color: CustomColors.orange,
                        // ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop('Cancel');
                      },
                    ),
                    TextButton(
                      child: const Icon(
                        Icons.search,
                        // color: CustomColors.orange,
                      ),
                      onPressed: () {
                        setState(() {});
                        if (txtName.text != '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
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
        ),
        body: Center(
          child: FutureBuilder(
            future: LogService.getLogs(
              isVisitor: isVisitor,
              name: txtName.text,
            ),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data['statusCode'] == 200) {
                  logs = snapshot.data['data'];
                  if (logs.length > 0) {
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        Offset _tapDownPosition = const Offset(0, 0);
                        return GestureDetector(
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
                                  await viewLog(logs[index].id);
                                  break;
                                case 2:
                                  showDialog(
                                      context: context,
                                      builder: (builder) {
                                        return AlertDialog(
                                          title: const Text('Notice'),
                                          content: Text(
                                              'Are you sure you want to delete log of ${logs[index].firstname} ${logs[index].lastname} (${logs[index].model} - ${logs[index].plate_no.toString().toUpperCase()})?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                var logDeleteResponse =
                                                    await LogService.delete(
                                                        logs[index].id);
                                                if (logDeleteResponse[
                                                        'statusCode'] ==
                                                    200) {
                                                  setState(() {});
                                                  Navigator.pop(context, 'YES');
                                                  showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Notice'),
                                                        content: const Text(
                                                            'Log deleted!'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  dialogContext,
                                                                  'OK');
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
                                                        title: const Text(
                                                            'Notice'),
                                                        content: const Text(
                                                            'Failed to delete log!'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  dialogContext,
                                                                  'OK');
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
                          onTap: () async {
                            await viewLog(logs[index].id);
                          },
                          child: Card(
                            child: ListTile(
                              leading: logs[index].is_vip == true
                                  ? const Icon(
                                      Icons.star,
                                      color: CustomColors.orange,
                                    )
                                  : const Icon(Icons.person),
                              contentPadding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              trailing: Icon(
                                logs[index].is_visitor == true
                                    ? Icons.person_pin_rounded
                                    : Icons.drive_eta,
                                size: 14,
                                color: logs[index].time_out == null
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: logs[index].firstname +
                                          ' ' +
                                          logs[index].lastname +
                                          '\n',
                                      style: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text: DateFormat('MM/dd/yy hh:mm a')
                                              .format(DateTime.parse(logs[index]
                                                  .time_in
                                                  .toString())) +
                                          '\n',
                                      style: TextStyle(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${logs[index].model!.toUpperCase()} [${logs[index].plate_no!.toUpperCase()}]',
                                      style: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
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
                return const Text('waiting...');
              } else {
                return const Text('waiting...');
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeftWithFade,
                child: AddLogView(),
              ),
            );
          },
          backgroundColor: CustomColors.orange,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
