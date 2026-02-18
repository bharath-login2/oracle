import 'dart:convert';

class AttendanceHistoryModel {
  bool status;
  String message;
  List<Datum> data;

  AttendanceHistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AttendanceHistoryModel.fromRawJson(String str) =>
      AttendanceHistoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) =>
      AttendanceHistoryModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: List<Datum>.from(
          (json["data"] as List<dynamic>? ?? []).map((x) => Datum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String action;
  String updatedDate;
  String updatedTime;
  String? updatedBy; 
  String description;
   String actionType;

  Datum({
    required this.action,
    required this.updatedDate,
    required this.updatedTime,
    required this.updatedBy,
    required this.description,
     required this.actionType,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) {
    String dateStr = json["updated_date"]?.toString() ?? "";
    return Datum(
      action: json["action"]?.toString() ?? "",
      updatedDate: dateStr, 
      updatedTime: json["updated_time"]?.toString() ?? "",
      updatedBy: json["updated_by"]?.toString(),
      description: json["description"]?.toString() ?? "",
       actionType: json["action_type"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "action": action,
        "updated_date": updatedDate,
        "updated_time": updatedTime,
        "updated_by": updatedBy,
        "description": description,
          "action_type": actionType,
      };
  DateTime? getParsedDate() {
    try {
      if (updatedDate.isNotEmpty) {
        final parts = updatedDate.split('-');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      }
    } catch (e) {
      print("Error parsing date $updatedDate: $e");
    }
    return null;
  }
  String getFormattedDate() {
    final parsed = getParsedDate();
    if (parsed != null) {
      return "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year}";
    }
    return updatedDate; 
  }
}