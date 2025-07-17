
// To parse this JSON data, do
//
//     final taskStatus = taskStatusFromJson(jsonString);

import 'dart:convert';

TaskStatus taskStatusFromJson(String str) => TaskStatus.fromJson(json.decode(str));

String taskStatusToJson(TaskStatus data) => json.encode(data.toJson());

class TaskStatus {
    bool status;
    List<TaskState> data;

    TaskStatus({
        required this.status,
        required this.data,
    });

    factory TaskStatus.fromJson(Map<String, dynamic> json) => TaskStatus(
        status: json["status"],
        data: List<TaskState>.from(json["data"].map((x) => TaskState.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class TaskState {
    String id;
    String status;

    TaskState({
        required this.id,
        required this.status,
    });

    factory TaskState.fromJson(Map<String, dynamic> json) => TaskState(
        id: json["id"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
    };
}
