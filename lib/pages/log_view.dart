import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class LogView extends StatefulWidget {
  final LogModel? log;
  const LogView({Key? key, required this.log}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Model: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.log!.model!)
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
                Text(widget.log!.plate_no!.toUpperCase())
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
                  widget.log!.time_out == null ? 'IN' : 'OUT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.log!.time_out == null
                        ? Colors.green
                        : Colors.red,
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
