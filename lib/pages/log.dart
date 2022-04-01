import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/services/log_service.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class Log extends StatefulWidget {
  const Log({Key? key}) : super(key: key);

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  @override
  Widget build(BuildContext context) {
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
        appBar: LoggedInAppBar(page: 'Log'),
        body: Center(
            child: FutureBuilder(
          future: LogService.getLogs(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: Text('waiting...'),
              );
            } else {
              if (snapshot.data.length > 0) {
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () async {
                        await showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              25, (index + 1) * 120, 20, 0),
                          items: popUpMenuItem,
                          elevation: 8.0,
                        ).then((value) async {
                          switch (value) {
                            case 1:
                              // await viewUser(snapshot.data[index].id);
                              break;
                            case 3:
                              showDialog(
                                  context: context,
                                  builder: (builder) {
                                    return AlertDialog(
                                      title: Text('Notice'),
                                      content: Text(
                                          'Are you sure you want to delete ${snapshot.data[index].username}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, 'Cancel');
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // UserService.delete(
                                            //     snapshot.data[index].id);
                                            setState(() {});
                                            Navigator.pop(context, 'YES');
                                          },
                                          child: const Text(
                                            'YES',
                                            style: TextStyle(color: Colors.red),
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
                        // await viewUser(snapshot.data[index].id);
                      },
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          trailing: Icon(
                            snapshot.data[index].is_visitor == true
                                ? Icons.person_pin_rounded
                                : Icons.drive_eta,
                            size: 14,
                            color: snapshot.data[index].time_out == null
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: DateFormat('MM/dd/yy hh:mm a').format(
                                          DateTime.parse(snapshot
                                              .data[index].time_in
                                              .toString())) +
                                      '\n',
                                  style: TextStyle(
                                    color: Colors.grey[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${snapshot.data[index].model!.toUpperCase()} [${snapshot.data[index].plate_no!.toUpperCase()}]',
                                  style: TextStyle(color: Colors.grey[900]),
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
                return const Text('No data');
              }
            }
          },
        )),
      ),
    );
  }
}
