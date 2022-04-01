import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vpass/models/VehicleModel.dart';
import 'package:vpass/services/shared_preferences_service.dart';

class VehicleService {
  static toggleStatus(String id, [String? log_id]) async {
    final response = await http.post(
        Uri.parse(dotenv.get('API_URL') + 'vehicle/toggle-status/' + id),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer ' + SharedPreferencesService.getString('session_token')
        },
        body: jsonEncode({'log_id': log_id ?? ''}));

    if (response.statusCode == 200) {
      return {
        'data': VehicleModel.fromJson(jsonDecode(response.body)),
        'statusCode': response.statusCode
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static getVehicle(String id) async {
    final response = await http.get(
      Uri.parse(dotenv.get('API_URL') + 'vehicle/' + id),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ' + SharedPreferencesService.getString('session_token')
      },
    );

    if (response.statusCode == 200) {
      return {
        'statusCode': 200,
        'data': VehicleModel.fromJson(jsonDecode(response.body))
      };
    } else {
      return {'statusCode': response.statusCode};
    }
  }

  static create(
    String userId,
    String model,
    String plateNo,
  ) async {
    final response = await http.post(
      Uri.parse(dotenv.get('API_URL') + 'vehicle'),
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
      Uri.parse(dotenv.get('API_URL') + 'vehicle/' + id),
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
