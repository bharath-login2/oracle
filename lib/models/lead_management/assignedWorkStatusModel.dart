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
  final NotificationSettings notification;
  final String unreadCounts;
  final String? unitNo;
  final String? siteLiftNo;
  final String? unitName;
  final String? siteLiftName;

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
    required this.notification,
    required this.unreadCounts,
    this.unitNo,
    this.siteLiftNo,
    this.unitName,
    this.siteLiftName,
  });

  factory AssignedWorkStatus.fromJson(Map<String, dynamic> json) =>
      AssignedWorkStatus(
        id: json["assign_id"]?.toString() ?? json["id"]?.toString() ?? "",
        projectId: json["project_id"]?.toString() ?? "",
        projectName: json["project_name"]?.toString() ?? "",
        title: json["title"]?.toString() ?? json["title_name"]?.toString() ?? "",
        titleName: json["title_name"]?.toString() ?? json["stage_name"]?.toString() ?? json["module_name"]?.toString() ?? json["title"]?.toString() ?? "",
        dueDate: json["due_date"] != null && json["due_date"] != ""
            ? DateTime.tryParse(json["due_date"])
            : null,
        priority: json["priority"]?.toString() ?? "",
        assignedTo: json["assigned_to"]?.toString() ?? "",
        createdAt: json["created_at"]?.toString() ?? "",
        loginTime: json["login_time"]?.toString() ?? "",
        logoutTime: json["logout_time"]?.toString() ?? "",
        tasks: json["tasks"] != null
            ? List<Task>.from(json["tasks"].map((x) => Task.fromJson(x)))
            : [],
        notification: NotificationSettings.fromJson(json["notification"] ??
            {
              "whatsup_notification": "0",
              "push_notification": "0",
              "on_start": "0",
              "on_save": "0",
              "on_complete": "0",
              "staff_ids": [],
              "participant_ids": []
            }),
        unreadCounts: json["unread_count"]?.toString() ?? "",
        unitNo: json["unit_name"]?.toString() ?? json["unit_no_name"]?.toString() ?? json["unit_no"]?.toString() ?? json["unitNo"]?.toString(),
        siteLiftNo: json["site_lift_name"]?.toString() ?? json["site_lift_no_name"]?.toString() ?? json["site_lift_no"]?.toString() ?? json["siteLiftNo"]?.toString(),
        unitName: json["unit_name"]?.toString() ?? json["unit_no_name"]?.toString() ?? json["unitName"]?.toString() ?? json["unit_no"]?.toString(),
        siteLiftName: json["site_lift_name"]?.toString() ?? json["site_lift_no_name"]?.toString() ?? json["siteLiftName"]?.toString() ?? json["site_lift_no"]?.toString(),
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
        "notification": notification.toJson(),
          "unread_count": unreadCounts,
        
      };

  firstWhere(bool Function(dynamic item) param0, {required Null Function() orElse}) {}
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
    this.completion = "0",
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
        "description": description,
        "remarks": remarks,
        "completion": completion,
        "is_delay": isDelay,
        "delay_type_id": delayTypeId,
        "loose_type_id": looseTypeId,
        "responsible_party": responsibleParty,
        "hours": hours,
      };
}

class NotificationSettings {
  final String whatsupNotification;
  final String pushNotification;
  final String onStart;
  final String onSave;
  final String onComplete;
  final List<String> staffIds;
  final List<String> participantIds;

  NotificationSettings({
    required this.whatsupNotification,
    required this.pushNotification,
    required this.onStart,
    required this.onSave,
    required this.onComplete,
    required this.staffIds,
    required this.participantIds,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        whatsupNotification: json["whatsup_notification"]?.toString() ?? "0",
        pushNotification: json["push_notification"]?.toString() ?? "0",
        onStart: json["on_start"]?.toString() ?? "0",
        onSave: json["on_save"]?.toString() ?? "0",
        onComplete: json["on_complete"]?.toString() ?? "0",
        staffIds: json["staff_ids"] != null
            ? List<String>.from(json["staff_ids"].map((x) => x.toString()))
            : [],
        participantIds: json["participant_ids"] != null
            ? List<String>.from(
                json["participant_ids"].map((x) => x.toString()))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "whatsup_notification": whatsupNotification,
        "push_notification": pushNotification,
        "on_start": onStart,
        "on_save": onSave,
        "on_complete": onComplete,
        "staff_ids": List<dynamic>.from(staffIds.map((x) => x)),
        "participant_ids": List<dynamic>.from(participantIds.map((x) => x)),
      };
}
