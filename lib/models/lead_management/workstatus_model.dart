

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
  final DateTime? dueDate;
  final String? priority;
  final String? assignedId;
  final String? assignedTo;
  final String createdAt;
  final String loginTime;
  final String logoutTime;
  final List<Task> tasks;
  final String? unitNo;
  final String? siteLiftNo;
  final String? unitName;
  final String? siteLiftName;
  final String? projectName;

  WorkStatus({
    required this.id,
    required this.projectId,
    required this.title,
    required this.title_name,
    required this.dueDate,
    required this.priority,
    required this.assignedId,
    required this.assignedTo,
    required this.createdAt,
    required this.loginTime,
    required this.logoutTime,
    required this.tasks,
    this.unitNo,
    this.siteLiftNo,
    this.unitName,
    this.siteLiftName,
    this.projectName,
  });

  factory WorkStatus.fromJson(Map<String, dynamic> json) => WorkStatus(
        id: json["id"]?.toString() ?? json["assign_id"]?.toString() ?? "",
        projectId: json["project_id"]?.toString() ?? "",
        title: json["title"]?.toString() ?? "",
        title_name: json["title_name"]?.toString() ?? json["stage_name"]?.toString() ?? json["module_name"]?.toString() ?? json["title"]?.toString() ?? "",
        dueDate: json["due_date"] != null && json["due_date"] != ""
            ? DateTime.tryParse(json["due_date"])
            : null,
        priority: json["priority"]?.toString() ?? "",
        assignedId: json["assigned_id"]?.toString() ?? "",
        assignedTo: json["assigned_to"]?.toString() ?? "",
        createdAt: json["created_at"]?.toString() ?? "",
        loginTime: json["login_time"]?.toString() ?? "",
        logoutTime: json["logout_time"]?.toString() ?? "",
        tasks: json["tasks"] != null ? List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))) : [],
        unitNo: json["unit_name"]?.toString() ?? json["unit_no_name"]?.toString() ?? json["unit_no"]?.toString() ?? json["unitNo"]?.toString(),
        siteLiftNo: json["site_lift_name"]?.toString() ?? json["site_lift_no_name"]?.toString() ?? json["site_lift_no"]?.toString() ?? json["siteLiftNo"]?.toString(),
        unitName: json["unit_name"]?.toString() ?? json["unit_no_name"]?.toString() ?? json["unitName"]?.toString() ?? json["unit_no"]?.toString(),
        siteLiftName: json["site_lift_name"]?.toString() ?? json["site_lift_no_name"]?.toString() ?? json["siteLiftName"]?.toString() ?? json["site_lift_no"]?.toString(),
        projectName: json["project_name"]?.toString() ?? json["projectName"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "project_id": projectId,
        "title": title,
        "title_name": title_name,
        "due_date": dueDate?.toIso8601String(),
        "priority": priority,
          "assigned_id": assignedId,
        "assigned_to": assignedTo,
        "created_at": createdAt,
        "login_time": loginTime,
        "logout_time": logoutTime,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  final String taskId;
  final String? activityId;
  final String taskName;
  final String status;
  final String description;
  final List<String> remarks;
  final String completion;
  final String? isDelay;
  final String? delayTypeId;
  final String? looseTypeId;
  final String? responsibleParty;
  final String? hours;

  Task({
    required this.taskId,
    this.activityId,
    required this.taskName,
    required this.status,
    required this.description,
    required this.remarks,
    this.completion = '0',
    this.isDelay,
    this.delayTypeId,
    this.looseTypeId,
    this.responsibleParty,
    this.hours,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskId: json["task_id"]?.toString() ?? "",
        activityId: json["activity_id"]?.toString() ?? json["task_id"]?.toString() ?? "",
        taskName: json["task_name"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        remarks: json["remarks"] != null ? List<String>.from(json["remarks"].map((x) => x.toString())) : [],
        completion: json["completion"]?.toString() ?? "0",
        isDelay: json["is_delay"]?.toString(),
        delayTypeId: json["delay_type_id"]?.toString() ?? json["delay_type"]?.toString(),
        looseTypeId: json["loose_type_id"]?.toString() ?? json["loose_type"]?.toString(),
        responsibleParty: json["responsible_party"]?.toString(),
        hours: json["hours"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "activity_id": activityId ?? taskId,
        "task_name": taskName,
        "status": status,
        "remarks": remarks,
        "completion": completion,
        "is_delay": isDelay,
        "delay_type_id": delayTypeId,
        "loose_type_id": looseTypeId,
        "responsible_party": responsibleParty,
        "hours": hours,
      };
}
