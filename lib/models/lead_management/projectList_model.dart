// To parse this JSON data, do
//
//     final projectList = projectListFromJson(jsonString);

import 'dart:convert';

ProjectList projectListFromJson(String str) => ProjectList.fromJson(json.decode(str));

String projectListToJson(ProjectList data) => json.encode(data.toJson());

class ProjectList {
    final List<Projects> data;
    final bool status;
    final String message;

    ProjectList({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ProjectList.fromJson(Map<String, dynamic> json) => ProjectList(
        data: List<Projects>.from(json["data"].map((x) => Projects.fromJson(x))),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
    };
}

class Projects {
    final String id;
    final String name;

    Projects({
        required this.id,
        required this.name,
    });

    factory Projects.fromJson(Map<String, dynamic> json) => Projects(
        id: json["id"]??"",
        name: json["name"]??"",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
