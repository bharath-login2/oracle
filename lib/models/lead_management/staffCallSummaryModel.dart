import 'dart:convert';

StaffCallSummery staffCallSummeryFromJson(String str) =>
    StaffCallSummery.fromJson(json.decode(str));

String staffCallSummeryToJson(StaffCallSummery data) =>
    json.encode(data.toJson());

class StaffCallSummery {
  final String status;
  final String message;
  final List<StaffCalls> data;

  StaffCallSummery({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StaffCallSummery.fromJson(Map<String, dynamic> json) =>
      StaffCallSummery(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<StaffCalls>.from((json["data"] as List).map((x) => StaffCalls.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class StaffCalls {
  final String userId;
  final String staffName;
  final String loginTime;
  final String logoutTime;
  final int totalCalls;
  final List<Call> calls;

  StaffCalls({
    required this.userId,
    required this.staffName,
    required this.loginTime,
    required this.logoutTime,
    required this.totalCalls,
    required this.calls,
  });

  factory StaffCalls.fromJson(Map<String, dynamic> json) => StaffCalls(
        userId: json["user_id"]?.toString() ?? "",
        staffName: json["staff_name"] ?? "",
        loginTime: json["login_time"] ?? "",
        logoutTime: json["logout_time"] ?? "",
        totalCalls: json["total_calls"] != null
            ? int.tryParse(json["total_calls"].toString()) ?? 0
            : 0,
        calls: json["calls"] != null
            ? List<Call>.from((json["calls"] as List).map((x) => Call.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
        "login_time": loginTime,
        "logout_time": logoutTime,
        "total_calls": totalCalls,
        "calls": List<dynamic>.from(calls.map((x) => x.toJson())),
      };
}

class Call {
  final String name;
  final String duration;
  final DateTime? startTime;
  final DateTime? endTime;

  Call({
    required this.name,
    required this.duration,
    required this.startTime,
    required this.endTime,
  });

  factory Call.fromJson(Map<String, dynamic> json) => Call(
        name: json["name"] ?? "",
        duration: json["duration"] ?? "",
        startTime: json["start_time"] != null
            ? DateTime.tryParse(json["start_time"])
            : null,
        endTime:
            json["end_time"] != null ? DateTime.tryParse(json["end_time"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "duration": duration,
        "start_time": startTime?.toIso8601String() ?? "",
        "end_time": endTime?.toIso8601String() ?? "",
      };
}
