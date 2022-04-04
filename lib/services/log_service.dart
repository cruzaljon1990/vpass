import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class LogService {
  static toggleStatus(String id) async {
    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'log/toggle-status/' + id),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );
    if (response.statusCode == 200) {
      return {
        'statusCode': response.statusCode,
        'data': LogModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static update(String id, Object? logData) async {
    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'log/' + id),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
      body: jsonEncode(logData),
    );
    if (response.statusCode == 200) {
      return {
        'statusCode': response.statusCode,
        'data': LogModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static getLog(String id) async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') + 'log/' + id),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );

    if (response.statusCode == 200) {
      return {
        'statusCode': response.statusCode,
        'data': LogModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static getLogs({
    int page = 1,
    int? isVisitor,
    String? name,
  }) async {
    String url = dotenv.get('API_URL') + 'log?page=' + page.toString();
    if (isVisitor != null) {
      url += '&is_visitor=' + isVisitor.toString();
    }
    if (name != null) {
      url += '&name=' + name.toString();
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );

    if (response.statusCode == 200) {
      return {
        'statusCode': response.statusCode,
        'data': LogModel.parseData(jsonDecode(response.body)['data'])
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static create(Object? logData) async {
    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'log'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
      body: jsonEncode(logData),
    );

    if (response.statusCode == 200) {
      return {
        'statusCode': response.statusCode,
        'data': LogModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static delete(String? id) async {
    if (id == null) {
      return false;
    }
    final response = await http.delete(
      Uri.parse(dotenv.get('API_URL') + 'log/' + id),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );

    if (response.statusCode == 200) {
      return {
        'statusCode': response.statusCode,
        'data': LogModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }
}
