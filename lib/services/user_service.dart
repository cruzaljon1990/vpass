import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vpass/models/UserModel.dart';
import 'package:vpass/pages/login.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class UserService {
  static Future login(String username, String password) async {
    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'user/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return response;
  }

  static signUp(
    String username,
    String password,
    String? firstname,
    String? middlename,
    String? lastname,
    String? type,
    String? birthday,
  ) async {
    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'user'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'firstname': firstname,
        'middlename': middlename,
        'lastname': lastname,
        'type': type,
        'birthday': birthday
      }),
    );

    return response;
  }

  static update(String? id, Object? userData) async {
    if (userData == null || id == null) {
      return;
    }

    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'user/' + id),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return {
        'statusCode': 200,
        'data': UserModel.fromJson(jsonDecode(response.body))
      };
    } else {
      print(response.body);
      return {'statusCode': response.statusCode};
    }
  }

  static getUsers(String? type) async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') + 'user?type=' + (type ?? 'driver')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );
    if (response.statusCode == 200) {
      return {
        'statusCode': 200,
        'data': UserModel.parseData(jsonDecode(response.body)['data'])
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static getUser(String id) async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') + 'user/' + id),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );
    if (response.statusCode == 200) {
      return {
        'statusCode': 200,
        'data': UserModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static getProfile() async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') + 'user/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );

    if (response.statusCode == 200) {
      return {
        'statusCode': 200,
        'data': UserModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static logout() async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') + 'user/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );
    SharedPreferencesService.remove('session_token');

    // if (response.statusCode == 200) {
    //   SharedPreferencesService.remove('session_token');
    // }
    return response;
  }

  static delete(String id) async {
    if (SharedPreferencesService.getString('session_user_type') == 'admin') {
      final response = await http.delete(
        Uri.parse(dotenv.get('API_URL') + 'user/' + id),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ' + SharedPreferencesService.getString('session_token')
        },
      );

      if (response.statusCode == 200) {
        SharedPreferencesService.remove('session_token');
        return true;
      }
    }
    return false;
  }
}
