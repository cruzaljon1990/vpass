import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:vpass/services/shared_preferences_service.dart';

class SitePrefsService {
  static getSitePrefs(String key) async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') + 'site-prefs/key/' + key),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );
    if (response.statusCode == 200) {
      return {'statusCode': 200, 'data': jsonDecode(response.body)};
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static setSitePrefs(String key, Object? value) async {
    final response = await http.post(
        Uri.parse(dotenv.get('API_URL') + 'site-prefs/key/' + key),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer ' + SharedPreferencesService.getString('session_token')
        },
        body: jsonEncode(value));

    return {'statusCode': response.statusCode};
  }

  static setManySitePrefs(List<Map<String, dynamic>> values) async {
    final response = await http.post(
        Uri.parse(dotenv.get('API_URL') + 'site-prefs/update-many'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer ' + SharedPreferencesService.getString('session_token')
        },
        body: jsonEncode({'values': values}));
    if (response.statusCode == 200) {
      return {'statusCode': 200, 'data': jsonDecode(response.body)};
    } else {
      return {'statusCode': response.statusCode};
    }
  }
}
