import 'package:flutter/material.dart';

class CustomColors {
  CustomColors._(); // this basically makes it so you can instantiate this class
  static const primaryOrange = 0xFFf7871e;
  static const MaterialColor orange = MaterialColor(
    primaryOrange,
    <int, Color>{
      50: Color(0xFFe0e0e0),
      100: Color(0xFFb3b3b3),
      200: Color(0xFF808080),
      300: Color(0xFF4d4d4d),
      400: Color(0xFF262626),
      500: Color(primaryOrange),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    },
  );
}
