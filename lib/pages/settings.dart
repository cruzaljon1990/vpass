import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vpass/logged_in_appbar.dart';
import 'package:vpass/services/site_prefs_service.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController txtVIPLimit = TextEditingController();
  TextEditingController txtNonVIPLimit = TextEditingController();

  @override
  void initState() {
    refreshSettings();
    super.initState();
  }

  void refreshSettings() async {
    txtVIPLimit.text =
        (await SitePrefsService.getSitePrefs('limit_vip'))['data']['value']
            .toString();
    txtNonVIPLimit.text =
        (await SitePrefsService.getSitePrefs('limit_non_vip'))['data']['value']
            .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoggedInAppBar(page: 'Settings'),
      body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Table(columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(4),
              }, children: [
                TableRow(children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 13,
                      right: 10,
                    ),
                    child: Text(
                      'VIP Limit:',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: txtVIPLimit,
                  )
                ]),
                TableRow(children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 13,
                      right: 10,
                    ),
                    child: Text(
                      'Non VIP Limit:',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: txtNonVIPLimit,
                  )
                ]),
              ]),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  var sitePrefsSaveResponse =
                      await SitePrefsService.setManySitePrefs([
                    {'key': 'limit_vip', 'value': txtVIPLimit.text},
                    {'key': 'limit_non_vip', 'value': txtNonVIPLimit.text},
                  ]);

                  if (sitePrefsSaveResponse['statusCode'] == 200) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Message'),
                          content: const Text('Settings updated!'),
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
                child: const Text('Save Settings'),
              )
            ],
          )),
    );
  }
}
