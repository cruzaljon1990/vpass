class LogModel {
  late String? id;
  late String? model;
  late String? plate_no;
  late String? firstname;
  late String? middlename;
  late String? lastname;
  late String? reason;
  late bool? is_visitor;
  late DateTime? time_in;
  late bool? is_in;
  late bool? is_vip;
  late bool? is_parking;
  DateTime? time_out;

  LogModel({
    required this.id,
    required this.model,
    required this.plate_no,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.reason,
    required this.is_visitor,
    required this.time_in,
    required this.is_in,
    required this.is_vip,
    required this.is_parking,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    LogModel log = LogModel(
      id: json['_id'],
      model: json['model'],
      plate_no: json['plate_no'],
      firstname: json['firstname'],
      middlename: json['middlename'],
      lastname: json['lastname'],
      reason: json['reason'],
      is_visitor: json['is_visitor'],
      time_in: DateTime.parse(json['time_in'] ?? ''),
      is_in: json['is_in'],
      is_vip: json['is_vip'],
      is_parking: json['is_parking'],
    );

    if (json['time_out'] != null) {
      log.time_out = DateTime.parse(json['time_out']);
    }

    return log;
  }

  static parseData(List<dynamic> data) {
    final parsed = data.cast<Map<String, dynamic>>();
    return (parsed.map((json) {
      LogModel user = LogModel.fromJson(json);
      return user;
    })).toList();
  }
}
