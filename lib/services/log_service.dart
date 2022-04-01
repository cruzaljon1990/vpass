import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vpass/models/LogModel.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class LogService {
  static toggleStatus(String? id, [String? log_id]) async {
    if (id != null) {
      final response = await http.post(
          Uri.parse(dotenv.get('API_URL') + 'log/toggle-status/' + id),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                'Bearer ' + SharedPreferencesService.getString('session_token')
          },
          body: jsonEncode({'log_id': log_id ?? ''}));
      if (response.statusCode == 200) {
        return true;
      }
    }
    return false;
  }

  static Future<LogModel?> getLog(String id, {int isVisitor = 0}) async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          'log/' +
          id +
          '?is_visitor=' +
          isVisitor.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );

    if (response.statusCode == 200) {
      return LogModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static Future<List<LogModel>?> getLogs({
    int page = 1,
    int? isVisitor,
  }) async {
    String url = dotenv.get('API_URL') + 'log?page=' + page.toString();
    if (isVisitor != null) {
      url += '&is_visitor=' + isVisitor.toString();
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
      return await LogModel.parseData(jsonDecode(response.body)['data']);
    } else {
      return [];
    }
  }

  static create(
    String userId,
    String model,
    String plateNo,
  ) async {
    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'log'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
      body: jsonEncode({
        'user_id': userId,
        'model': model,
        'plate_no': plateNo,
      }),
    );
    return response;
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
      return true;
    }
    return false;
  }
}
