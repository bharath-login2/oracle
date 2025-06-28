// To parse this JSON data, do
//
//     final workStatusModel = workStatusModelFromJson(jsonString);

import 'dart:convert';

WorkStatusModel workStatusModelFromJson(String str) =>
    WorkStatusModel.fromJson(json.decode(str));

String workStatusModelToJson(WorkStatusModel data) =>
    json.encode(data.toJson());

class WorkStatusModel {
  final List<WorkStatus> data;
  final bool status;
  final String message;

  WorkStatusModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory WorkStatusModel.fromJson(Map<String, dynamic> json) =>
      WorkStatusModel(
        data: List<WorkStatus>.from(
            json["data"].map((x) => WorkStatus.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class WorkStatus {
  final String id;
  final String projectId;
  final String title;
  final String title_name;
  final String createdAt;
  final String loginTime;
  final String logoutTime;
  final List<Task> tasks;

  WorkStatus({
    required this.id,
    required this.projectId,
    required this.title,
    required this.title_name,
    required this.createdAt,
    required this.loginTime,
    required this.logoutTime,
    required this.tasks,
  });

  factory WorkStatus.fromJson(Map<String, dynamic> json) => WorkStatus(
        id: json["id"] ?? "",
        projectId: json["project_id"] ?? "",
        title: json["title"] ?? "",
        title_name: json["title_name"] ?? "",
        createdAt: json["created_at"] ?? "",
        loginTime: json["login_time"] ?? "",
        logoutTime: json["logout_time"] ?? "",
        tasks: List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "project_id": projectId,
        "title": title,
        "title_name": title_name,
        "created_at": createdAt,
        "login_time": loginTime,
        "logout_time": logoutTime,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  final String taskId;
  final String taskName;
  final String status;
  final List<String> remarks;

  Task({
    required this.taskId,
    required this.taskName,
    required this.status,
    required this.remarks,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskId: json["task_id"] ?? "",
        taskName: json["task_name"] ?? "",
        status: json["status"] ?? "",
        remarks:
            json["remarks"] != null ? List<String>.from(json["remarks"]) : [],
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "task_name": taskName,
        "status": status,
        "remarks": remarks,
      };
}
