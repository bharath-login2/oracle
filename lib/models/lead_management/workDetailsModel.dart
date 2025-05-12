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
  final String title;
  final DateTime createdAt;
  final String startTime;
  final String endTime;
  final String totalDuration;
  final String gapDuration;
  final List<Task> tasks;

  workDetailsList({
    required this.id,
    required this.projectId,
    required this.title,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.gapDuration,
    required this.tasks,
  });

  factory workDetailsList.fromJson(Map<String, dynamic> json) => workDetailsList(
        id: json["id"] ?? "",
        projectId: json["project_id"] ?? "",
        title: json["title"] ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        totalDuration: json["total_duration"] ?? "",
        gapDuration: json["gap_duration"] ?? "",
        tasks: json["tasks"] != null
            ? List<Task>.from(json["tasks"].map((x) => Task.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "project_id": projectId,
        "title": title,
        "created_at": createdAt.toIso8601String(),
        "start_time": startTime,
        "end_time": endTime,
        "total_duration": totalDuration,
        "gap_duration": gapDuration,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  final String taskId;
  final String taskName;
  final String status;
  final String taskStart;
  final String taskEnd;

  Task({
    required this.taskId,
    required this.taskName,
    required this.status,
     required this.taskStart,
      required this.taskEnd,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskId: json["task_id"] ?? "",
        taskName: json["task_name"] ?? "",
        status: json["status"] ?? "",
          taskStart: json["task_start"] ?? "",
            taskEnd: json["task_end"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "task_name": taskName,
        "status": status,
          "task_start": taskStart,
            "task_end": taskEnd,
      };
}
