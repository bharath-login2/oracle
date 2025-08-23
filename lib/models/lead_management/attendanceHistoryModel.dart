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

    factory AttendanceHistoryModel.fromRawJson(String str) => AttendanceHistoryModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) => AttendanceHistoryModel(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String action;
    DateTime updatedDate;
    String updatedTime;
    String updatedBy;
    String description;

    Datum({
        required this.action,
        required this.updatedDate,
        required this.updatedTime,
        required this.updatedBy,
        required this.description,

    });

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        action: json["action"]??"",
        updatedDate: DateTime.parse(json["updated_date"]??""),
        updatedTime: json["updated_time"]??"",
        updatedBy: json["updated_by"]??"",
         description: json["description"]??"",
    );

    Map<String, dynamic> toJson() => {
        "action": action,
        "updated_date": "${updatedDate.year.toString().padLeft(4, '0')}-${updatedDate.month.toString().padLeft(2, '0')}-${updatedDate.day.toString().padLeft(2, '0')}",
        "updated_time": updatedTime,
        "updated_by": updatedBy,
         "description": description,
    };
}
