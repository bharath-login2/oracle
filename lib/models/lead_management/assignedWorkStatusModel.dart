// To parse this JSON data, do
//
//     final workStatusModel = workStatusModelFromJson(jsonString);

import 'dart:convert';

AssignedWorkStatusModel workStatusModelFromJson(String str) =>
    AssignedWorkStatusModel.fromJson(json.decode(str));

String workStatusModelToJson(AssignedWorkStatusModel data) =>
    json.encode(data.toJson());

class AssignedWorkStatusModel {
  final List<AssignedWorkStatus> data;
  final bool status;
  final String message;

  AssignedWorkStatusModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory AssignedWorkStatusModel.fromJson(Map<String, dynamic> json) =>
      AssignedWorkStatusModel(
        data: List<AssignedWorkStatus>.from(
            json["data"].map((x) => AssignedWorkStatus.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class AssignedWorkStatus {
  final String id;
  final String projectId;
  final String projectName;
  final String title;
  final String titleName;
  final DateTime? dueDate;
  final String? priority;
  final String? assignedTo;
  final String createdAt;
  final String loginTime;
  final String logoutTime;
  final List<Task> tasks;

  AssignedWorkStatus({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.titleName,
    required this.dueDate,
    required this.priority,
    required this.assignedTo,
    required this.createdAt,
    required this.loginTime,
    required this.logoutTime,
    required this.tasks,
  });

  factory AssignedWorkStatus.fromJson(Map<String, dynamic> json) =>
      AssignedWorkStatus(
        id: json["assign_id"] ?? "",
        projectId: json["project_id"] ?? "",
        projectName: json["project_name"] ?? "",
        title: json["title"] ?? "",
        titleName: json["title_name"] ?? "",
        dueDate: json["due_date"] != null && json["due_date"] != ""
            ? DateTime.tryParse(json["due_date"])
            : null,
        priority: json["priority"] ?? "",
        assignedTo: json["assigned_to"] ?? "",
        createdAt: json["created_at"] ?? "",
        loginTime: json["login_time"] ?? "",
        logoutTime: json["logout_time"] ?? "",
        tasks: List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "assign_id": id,
        "project_id": projectId,
        "project_name": projectName,
        "title": title,
        "title_name": titleName,
        "due_date": dueDate?.toIso8601String(),
        "priority": priority,
        "assigned_to": assignedTo,
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
  final String description;
  final List<String> remarks;
  Task({
    required this.taskId,
    required this.taskName,
    required this.status,
    required this.description,
    required this.remarks,
  });
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskId: json["task_id"] ?? "",
        taskName: json["task_name"] ?? "",
        status: json["status"] ?? "",
        description: json["description"] ?? "",
        remarks:
            json["remarks"] != null ? List<String>.from(json["remarks"]) : [],
      );
  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "task_name": taskName,
        "status": status,
        "description": description,
        "remarks": remarks,
      };
}
