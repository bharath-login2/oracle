// To parse this JSON data, do
//
//     final workDetailsModel = workDetailsModelFromJson(jsonString);

import 'dart:convert';

WorkDetailsModel workDetailsModelFromJson(String str) =>
    WorkDetailsModel.fromJson(json.decode(str));

String workDetailsModelToJson(WorkDetailsModel data) =>
    json.encode(data.toJson());

class WorkDetailsModel {
  final List<workDetailsList> data;
  final bool status;
  final String message;

  WorkDetailsModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory WorkDetailsModel.fromJson(Map<String, dynamic> json) =>
      WorkDetailsModel(
        data: List<workDetailsList>.from(json["data"].map((x) => workDetailsList.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class workDetailsList {
  final String id;
  final String projectId;
    final String customerName;
  final String title;
   final String titleName;
  final DateTime createdAt;
  final String startTime;
  final String endTime;
  final String totalDuration;
  final String latitude;
   final String longitude;
  final String gapDuration;
     final String is_paused;
  final List<Task> tasks;
   final String loginTime;
    final String logoutTime;
 final String totalIdeaTime;
 final String totalWorkingTime;


  workDetailsList({
    required this.id,
    required this.projectId,
        required this.customerName,
    required this.title,
     required this.titleName,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
      required this.latitude,
      required this.longitude,
    required this.gapDuration,
    required this.is_paused,
    required this.tasks,
     required this.loginTime,
      required this.logoutTime,
      required this.totalIdeaTime,
      required this.totalWorkingTime,


  });

  factory workDetailsList.fromJson(Map<String, dynamic> json) => workDetailsList(
        id: json["id"] ?? "",
        projectId: json["project_id"] ?? "",
         customerName: json["customer_name"] ?? "",
        title: json["title"] ?? "",
          titleName: json["title_name"] ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        totalDuration: json["total_duration"] ?? "",
         latitude: json["latitude"] ?? "",
           longitude: json["longitude"] ?? "",
        gapDuration: json["gap_duration"] ?? "",
           is_paused: json["is_paused"] ?? "",
        tasks: json["tasks"] != null
            ? List<Task>.from(json["tasks"].map((x) => Task.fromJson(x)))
            : [],
        loginTime: json["login_time"] ?? "",
         logoutTime: json["logout_time"] ?? "",
          totalIdeaTime: json["total_gap_duration"] ?? "",
           totalWorkingTime: json["total_work_duration"] ?? "",

      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "project_id": projectId,
            "customer_name": customerName,
        "title": title,
           "title_name": titleName,
        "created_at": createdAt.toIso8601String(),
        "start_time": startTime,
        "end_time": endTime,
        "total_duration": totalDuration,
         "latitude": latitude,
          "longitude": longitude,
        "gap_duration": gapDuration,
          "is_paused": is_paused,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
         "login_time": loginTime,
          "logout_time": logoutTime,
           "total_gap_duration": totalIdeaTime,
            "total_work_duration": totalWorkingTime,

      };
}

class Task {
  final String taskId;
  final String taskName;
  final String status;
  final String taskStart;
  final String taskEnd;
  final List<String> remarks; 

  Task({
    required this.taskId,
    required this.taskName,
    required this.status,
    required this.taskStart,
    required this.taskEnd,
    required this.remarks, 
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskId: json["task_id"] ?? "",
        taskName: json["task_name"] ?? "",
        status: json["status"] ?? "",
        taskStart: json["task_start"] ?? "",
        taskEnd: json["task_end"] ?? "",
        remarks: json["remarks"] != null
            ? List<String>.from(json["remarks"])
            : [],
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "task_name": taskName,
        "status": status,
        "task_start": taskStart,
        "task_end": taskEnd,
        "remarks": remarks, 
      };
}

