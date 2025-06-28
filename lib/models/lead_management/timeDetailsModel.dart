// To parse this JSON data, do
//
//     final timeDetailsModel = timeDetailsModelFromJson(jsonString);

import 'dart:convert';

TimeDetailsModel timeDetailsModelFromJson(String str) =>
    TimeDetailsModel.fromJson(json.decode(str));

String timeDetailsModelToJson(TimeDetailsModel data) =>
    json.encode(data.toJson());

class TimeDetailsModel {
  TimeDetail data;
  bool status;
  String message;

  TimeDetailsModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory TimeDetailsModel.fromJson(Map<String, dynamic> json) =>
      TimeDetailsModel(
        data: TimeDetail.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
      };
}

class TimeDetail {
  String loginTime;
  String logoutTime;
  String totalGapDuration;
  String totalWorkDuration;
  String taskStatus;
  String startTime;
  String endTime;
  String totalIncomingDuration;
  String totalOutgoingDuration;
  String totalIdealTime;

  TimeDetail({
    required this.loginTime,
    required this.logoutTime,
    required this.totalGapDuration,
    required this.totalWorkDuration,
    required this.taskStatus,
    required this.startTime,
    required this.endTime,
    required this.totalIncomingDuration,
    required this.totalOutgoingDuration,
    required this.totalIdealTime,
  });

  factory TimeDetail.fromJson(Map<String, dynamic> json) => TimeDetail(
        loginTime: json["login_time"] ?? "",
        logoutTime: json["logout_time"] ?? "",
        totalGapDuration: json["total_gap_duration"] ?? "",
        totalWorkDuration: json["total_work_duration"] ?? "",
        taskStatus: json["task_status"] ?? "",
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        totalIncomingDuration: json["total_incoming_duration"] ?? "",
        totalOutgoingDuration: json["total_outgoing_duration"] ?? "",
        totalIdealTime: json["total_ideal_time"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "login_time": loginTime,
        "logout_time": logoutTime,
        "total_gap_duration": totalGapDuration,
        "total_work_duration": totalWorkDuration,
        "task_status": taskStatus,
        "start_time": startTime,
        "end_time": endTime,
        "total_incoming_duration": totalIncomingDuration,
        "total_outgoing_duration": totalOutgoingDuration,
        "total_ideal_time": totalIdealTime,
      };
}
