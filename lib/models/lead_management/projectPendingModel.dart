// To parse this JSON data, do
//
//     final projectPendingReport = projectPendingReportFromJson(jsonString);

import 'dart:convert';

ProjectPendingReport projectPendingReportFromJson(String str) =>
    ProjectPendingReport.fromJson(json.decode(str));

String projectPendingReportToJson(ProjectPendingReport data) =>
    json.encode(data.toJson());

class ProjectPendingReport {
  bool status;
  List<ProjectSummary> projectSummary;

  ProjectPendingReport({
    required this.status,
    required this.projectSummary,
  });

  factory ProjectPendingReport.fromJson(Map<String, dynamic> json) =>
      ProjectPendingReport(
        status: json["status"],
        projectSummary: List<ProjectSummary>.from(
            json["project_summary"].map((x) => ProjectSummary.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "project_summary":
            List<dynamic>.from(projectSummary.map((x) => x.toJson())),
      };
}

class ProjectSummary {
  String projectName;
  String customerName;
  List<Staff> staffs;

  ProjectSummary({
    required this.projectName,
    required this.customerName,
    required this.staffs,
  });

  factory ProjectSummary.fromJson(Map<String, dynamic> json) => ProjectSummary(
        projectName: json["project_name"],
        customerName: json["customer_name"],
        staffs: List<Staff>.from(json["staffs"].map((x) => Staff.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "project_name": projectName,
        "customer_name": customerName,
        "staffs": List<dynamic>.from(staffs.map((x) => x.toJson())),
      };
}

class Staff {
  String staffName;
  List<Task> tasks;

  Staff({
    required this.staffName,
    required this.tasks,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        staffName: json["staff_name"],
        tasks: List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "staff_name": staffName,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  String taskName;
  String status;
  String startTime;
  String endTime;
  String workedDate;
  List<String> remarks;

  Task({
    required this.taskName,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.workedDate,
    required this.remarks,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskName: json["task_name"]??"",
        status: json["status"]??"",
        startTime: json["start_time"]??"",
        endTime: json["end_time"]??"",
        workedDate: json["worked_date"]??"",
      remarks: List<String>.from(json["remarks"]?.map((x) => x) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "task_name": taskName,
        "status": status,
        "start_time": startTime,
        "end_time": endTime,
        "worked_date": workedDate,
        "remarks": List<dynamic>.from(remarks.map((x) => x)),
      };
}
