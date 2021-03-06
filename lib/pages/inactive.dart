import 'package:flutter/material.dart';

class Inactive extends StatelessWidget {
  const Inactive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('VPass | Inactive Account')),
      body: const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text(
            'Account is not active! Please wait \'til your account become active. Thank you',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
