// To parse this JSON data, do
//
//     final attendanceDataAllModel = attendanceDataAllModelFromJson(jsonString);

import 'dart:convert';

AttendanceDataAllModel attendanceDataAllModelFromJson(String str) =>
    AttendanceDataAllModel.fromJson(json.decode(str));

String attendanceDataAllModelToJson(AttendanceDataAllModel data) =>
    json.encode(data.toJson());

class AttendanceDataAllModel {
  bool status;
  String message;
  Data data;

  AttendanceDataAllModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AttendanceDataAllModel.fromJson(Map<String, dynamic> json) =>
      AttendanceDataAllModel(
        status: json["status"] ?? false,
        message: json["message"] ?? '',
        data: Data.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  List<AttendanceItem> attendance;
  List<LeaveItem> leave;

  Data({
    required this.attendance,
    required this.leave,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        attendance: json["attendance"] != null
            ? List<AttendanceItem>.from(
                json["attendance"].map((x) => AttendanceItem.fromJson(x)))
            : [],
        leave: json["leave"] != null
            ? List<LeaveItem>.from(json["leave"].map((x) => LeaveItem.fromJson(x)))
            : [],
      );

 // bool get isNotEmpty => null;

  Map<String, dynamic> toJson() => {
        "attendance": List<dynamic>.from(attendance.map((x) => x.toJson())),
        "leave": List<dynamic>.from(leave.map((x) => x.toJson())),
      };
}

class AttendanceItem {
  String staffId;
  String staffName;
  String status;

  AttendanceItem({
    required this.staffId,
    required this.staffName,
    required this.status,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) => AttendanceItem(
        staffId: json["staff_id"] ?? '',
        staffName: json["staff_name"] ?? '',
        status: json["status"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "staff_name": staffName,
        "status": status,
      };
}

class LeaveItem {
  String staffId;
  String staffName;
  String status;
  String leaveType;
  String reason;

  LeaveItem({
    required this.staffId,
    required this.staffName,
    required this.status,
    required this.leaveType,
    required this.reason,
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) => LeaveItem(
        staffId: json["staff_id"] ?? '',
        staffName: json["staff_name"] ?? '',
        status: json["status"] ?? '',
        leaveType: json["leave_type"] ?? '',
        reason: json["reason"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "staff_name": staffName,
        "status": status,
        "leave_type": leaveType,
        "reason": reason,
      };
}
