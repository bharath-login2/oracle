// To parse this JSON data, do
//
//     final priorityStatus = priorityStatusFromJson(jsonString);

import 'dart:convert';

PriorityStatus priorityStatusFromJson(String str) => PriorityStatus.fromJson(json.decode(str));

String priorityStatusToJson(PriorityStatus data) => json.encode(data.toJson());

class PriorityStatus {
    bool status;
    List<PrioState> data;

    PriorityStatus({
        required this.status,
        required this.data,
    });

    factory PriorityStatus.fromJson(Map<String, dynamic> json) => PriorityStatus(
        status: json["status"],
        data: List<PrioState>.from(json["data"].map((x) => PrioState.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class PrioState {
    String id;
    String priority;

    PrioState({
        required this.id,
        required this.priority,
    });

    factory PrioState.fromJson(Map<String, dynamic> json) => PrioState(
        id: json["id"],
        priority: json["priority"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "priority": priority,
    };
}
