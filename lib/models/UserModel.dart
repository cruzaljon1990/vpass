import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:vpass/models/VehicleModel.dart';

class UserModel {
  late String? id;
  late String username;
  late String? password;
  late String firstname;
  late String middlename;
  late String lastname;
  late String type;
  late DateTime? birthday;
  late int age;
  late bool? hasVehiclesInside;
  late bool? is_vip;
  late bool? is_super;
  late int? status;
  late List<dynamic>? vehicles;

  UserModel(
      {required this.id,
      required this.username,
      required this.password,
      required this.firstname,
      required this.middlename,
      required this.lastname,
      required this.type,
      required this.birthday,
      required this.age,
      required this.hasVehiclesInside,
      required this.is_vip,
      required this.is_super,
      required this.status,
      required this.vehicles});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      password: json['password'],
      firstname: json['firstname'],
      middlename: json['middlename'],
      lastname: json['lastname'],
      type: json['type'],
      birthday: DateTime.parse(json['birthday']),
      age: json['age'],
      hasVehiclesInside: json['has_vehicles_inside'],
      is_vip: json['is_vip'],
      is_super: json['is_super'],
      status: json['status'],
      vehicles: json['vehicles'],
    );
  }

  static List<UserModel> parseData(List<dynamic> data) {
    final parsed = data.cast<Map<String, dynamic>>();
    return (parsed.map((json) {
      UserModel user = UserModel.fromJson(json);
      return user;
    })).toList();
  }
}
