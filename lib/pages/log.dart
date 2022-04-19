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
  final ScrollController _scrollController = ScrollController();
  TextEditingController txtName = TextEditingController(text: '');
  bool initLoading = false, loading = false, allLoaded = false;
  var logs = [], page = 1;
  int? isVisitor;

  @override
  void initState() {
    super.initState();
    initLoading = true;
    loadLogs(page: page);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        loadLogs(page: ++page);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void resetLogs() {
    setState(() {
      allLoaded = false;
      initLoading = true;
      logs = [];
    });
    page = 1;
    loadLogs(page: page);
  }

  void loadLogs({int page: 1}) async {
    if (allLoaded) {
      return;
    }
    setState(() {
      loading = true;
    });
    var getLogsResponse = await LogService.getLogs(
        isVisitor: isVisitor, name: txtName.text, page: page);
    if (getLogsResponse['statusCode'] == 200) {
      if (getLogsResponse['data'].isNotEmpty) {
        logs.addAll(getLogsResponse['data']);
      }
      setState(() {
        initLoading = false;
        loading = false;
        allLoaded = getLogsResponse['data'].isEmpty;
      });
    } else if (getLogsResponse['statusCode'] == 401) {
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
    return RefreshIndicator(
      onRefresh: () async {
        resetLogs();
      },
      child: Scaffold(
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
                        if (txtName.text != '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                              content: Text('Results for: ' + txtName.text),
                            ),
                          );
                        }
                        Navigator.of(context).pop('OK');
                        setState(() {
                          allLoaded = false;
                          initLoading = true;
                          logs = [];
                        });
                        page = 1;
                        loadLogs(page: page);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (!initLoading) {
              if (logs.isNotEmpty) {
                return Stack(children: [
                  ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index < logs.length) {
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
                                                              resetLogs();
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
                      } else {
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: 50,
                          child: Center(child: Text('All users are loaded!')),
                        );
                      }
                    },
                    itemCount: logs.length + (allLoaded ? 1 : 0),
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
                  ]
                ]);
              } else {
                return const Center(child: Text('No Data'));
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: CustomColors.orange,
                ),
              );
            }
          },
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
