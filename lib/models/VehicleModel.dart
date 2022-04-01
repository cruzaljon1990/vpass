class VehicleModel {
  late String? id;
  late String model;
  late String plate_no;
  late List<dynamic>? logs;
  late bool? is_in;

  VehicleModel(
      {required this.id,
      required this.model,
      required this.plate_no,
      required this.is_in,
      required this.logs});

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id'],
      model: json['model'],
      plate_no: json['plate_no'],
      is_in: json['is_in'],
      logs: json['logs'],
    );
  }

  static parseData(List<Map<String, dynamic>>? data) {
    if (data != null) {
      final parsed = data.cast<Map<String, dynamic>>();
      return parsed.map(
        (e) {
          return VehicleModel.fromJson(e);
        },
      ).toList();
    }
    return null;
  }
}
