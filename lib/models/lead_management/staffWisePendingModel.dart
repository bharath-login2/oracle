import 'dart:convert';

StaffSummaryReport staffSummaryReportFromJson(String str) =>
    StaffSummaryReport.fromJson(json.decode(str));

String staffSummaryReportToJson(StaffSummaryReport data) =>
    json.encode(data.toJson());

class StaffSummaryReport {
  bool status;
  List<Summary> summary;

  StaffSummaryReport({
    required this.status,
    required this.summary,
  });

  factory StaffSummaryReport.fromJson(Map<String, dynamic> json) =>
      StaffSummaryReport(
        status: json["status"],
        summary: json["summary"] != null
            ? List<Summary>.from(
                json["summary"].map((x) => Summary.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "summary": List<dynamic>.from(summary.map((x) => x.toJson())),
      };

  @override
  String toString() =>
      'StaffSummaryReport(status: $status, summaryCount: ${summary.length})';
}

class Summary {
  String userId;
  String staffName;
  String loginTime;
  String logoutTime;
  List<Project> projects;

  Summary({
    required this.userId,
    required this.staffName,
    this.loginTime = '',
    this.logoutTime = '',
    required this.projects,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        userId: json["user_id"].toString(),
        staffName: json["staff_name"] ?? '',
        loginTime: json["login_time"] ?? '',
        logoutTime: json["logout_time"] ?? '',
        projects: json["projects"] != null
            ? List<Project>.from(
                json["projects"].map((x) => Project.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
        "login_time": loginTime,
        "logout_time": logoutTime,
        "projects": List<dynamic>.from(projects.map((x) => x.toJson())),
      };
}

class Project {
  String projectId;
  String projectName;
  String customerId;
  String customerName;
  String module;
  List<Task> tasks;

  Project({
    required this.projectId,
    required this.projectName,
    required this.customerId,
    required this.customerName,
    required this.module,
    required this.tasks,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        projectId: json["project_id"].toString(),
        projectName: json["project_name"] ?? '',
        customerId: json["customer_id"].toString(),
        customerName: json["customer_name"] ?? '',
        module: json["module"] ?? '',
        tasks: json["tasks"] != null
            ? List<Task>.from(json["tasks"].map((x) => Task.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "project_id": projectId,
        "project_name": projectName,
        "customer_id": customerId,
        "customer_name": customerName,
        "module": module,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  String attendanceId;
  String projectId;
  String customerId;
  String taskName;
  String status;
  String startTime;
  String endTime;
  List<String> remarks;
  String module;
  String name;
  String date;
  String dueDate;
  String priority;
  String assignedTo;
  String assignedBy;
  Task({
    required this.attendanceId,
    required this.projectId,
    required this.customerId,
    required this.taskName,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.remarks,
    required this.module,
    required this.name,
    required this.date,
    required this.dueDate,
    required this.priority,
    required this.assignedTo,
     required this.assignedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        attendanceId: json["attendance_id"].toString(),
        projectId: json["project_id"].toString(),
        customerId: json["customer_id"].toString(),
        taskName: json["task_name"] ?? '',
        status: json["status"].toString(),
        startTime: json["start_time"] ?? '',
        endTime: json["end_time"] ?? '',
        remarks: json["remarks"] != null
            ? List<String>.from(json["remarks"].map((x) => x))
            : [],
        module: json["module"] ?? '',
        name: json["name"] ?? '',
        date: json["date"] ?? '',
        dueDate: json["due_date"] ?? '',
        priority: json["priority"] ?? '',
        assignedTo: json["assigned_to"] ?? '',
         assignedBy: json["assigned_by"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "attendance_id": attendanceId,
        "project_id": projectId,
        "customer_id": customerId,
        "task_name": taskName,
        "status": status,
        "start_time": startTime,
        "end_time": endTime,
        "remarks": List<dynamic>.from(remarks.map((x) => x)),
        "module": module,
        "name": name,
        "date": date,
        "due_date": dueDate,
        "priority": priority,
        "assigned_to": assignedTo,
         "assigned_by": assignedBy,
      };
}
