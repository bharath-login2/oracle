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
        data: List<workDetailsList>.from(
            json["data"].map((x) => workDetailsList.fromJson(x))),
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
  final String projectName;
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
  final bool showRestart;
  final String currentStatus;
  final List<Task> tasks;
  final List<Assign> assigns;
  final String loginTime;
  final String logoutTime;
  final String TimeDifference;
  final String totalIdeaTime;
  final String totalWorkingTime;

  workDetailsList({
    required this.id,
    required this.projectName,
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
    this.showRestart = false,
    this.currentStatus = "",
    required this.tasks,
    required this.assigns,
    required this.loginTime,
    required this.logoutTime,
    required this.TimeDifference,
    required this.totalIdeaTime,
    required this.totalWorkingTime,
  });

  factory workDetailsList.fromJson(Map<String, dynamic> json) =>
      workDetailsList(
        id: json["id"]?.toString() ?? "",
        projectName: json["project_name"]?.toString() ?? "",
        projectId: json["project_id"]?.toString() ?? "",
        customerName: json["customer_name"]?.toString() ?? "",
        title: json["title"]?.toString() ?? "",
        titleName: json["title_name"]?.toString() ?? "",
        createdAt: json["created_at"] != null &&
                json["created_at"].toString().trim().isNotEmpty
            ? (DateTime.tryParse(json["created_at"].toString().trim()) ??
                DateTime.now())
            : DateTime.now(),
        startTime: json["start_time"]?.toString() ?? "",
        endTime: json["end_time"]?.toString() ?? "",
        totalDuration: json["total_duration"]?.toString() ?? "",
        latitude: json["latitude"]?.toString() ?? "",
        longitude: json["longitude"]?.toString() ?? "",
        gapDuration: json["gap_duration"]?.toString() ?? "",
        is_paused: json["is_paused"]?.toString() ?? "",
        showRestart: json["show_restart"] == true ||
            json["show_restart"]?.toString().toLowerCase() == "true" ||
            json["show_restart"]?.toString() == "1",
        currentStatus: json["current_status"]?.toString() ?? "",
        tasks: json["tasks"] != null && json["tasks"] is List
            ? List<Task>.from(json["tasks"].map((x) => Task.fromJson(x)))
            : [],
        assigns: json["assigns"] != null && json["assigns"] is List
            ? List<Assign>.from(json["assigns"].map((x) => Assign.fromJson(x)))
            : [],
        loginTime: json["login_time"]?.toString() ?? "",
        logoutTime: json["logout_time"]?.toString() ?? "",
        TimeDifference: json["time_difference"]?.toString() ?? "",
        totalIdeaTime: json["total_gap_duration"]?.toString() ?? "",
        totalWorkingTime: json["total_work_duration"]?.toString() ?? "",
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "project_name": projectName,
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
        "show_restart": showRestart,
        "current_status": currentStatus,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
        "assigns": List<dynamic>.from(assigns.map((x) => x.toJson())),
        "login_time": loginTime,
        "logout_time": logoutTime,
        "time_difference": TimeDifference,
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
        remarks:
            json["remarks"] != null ? List<String>.from(json["remarks"]) : [],
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

class Assign {
  final String dueDate;
  final String priority;
  final String assignedBy;

  Assign({
    required this.dueDate,
    required this.priority,
    required this.assignedBy,
  });

  factory Assign.fromJson(Map<String, dynamic> json) => Assign(
        dueDate: json["due_date"] ?? "",
        priority: json["priority"] ?? "",
        assignedBy: json["assigned_by"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "due_date": dueDate,
        "priority": priority,
        "assigned_by": assignedBy,
      };
}
