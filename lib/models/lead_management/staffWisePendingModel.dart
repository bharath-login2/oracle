import 'dart:convert';

StaffSummaryReport staffSummaryReportFromJson(String str) => 
    StaffSummaryReport.fromJson(json.decode(str));

String staffSummaryReportToJson(StaffSummaryReport data) => 
    json.encode(data.toJson());

class StaffSummaryReport {
  final bool status;
  final List<Summary> summary;

  StaffSummaryReport({
    required this.status,
    required this.summary,
  });

  factory StaffSummaryReport.fromJson(Map<String, dynamic> json) => StaffSummaryReport(
    status: json["status"] ?? false,
    summary: json["summary"] != null 
        ? List<Summary>.from(json["summary"].map((x) => Summary.fromJson(x)))
        : <Summary>[],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "summary": List<dynamic>.from(summary.map((x) => x.toJson())),
  };
}

class Summary {
  final String userId;
  final String staffName;
  final String loginTime;
  final String logoutTime;
  final List<Project> projects;

  Summary({
    required this.userId,
    required this.staffName,
    this.loginTime = '',
    this.logoutTime = '',
    required this.projects,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    userId: json["user_id"]?.toString() ?? '',
    staffName: json["staff_name"]?.toString() ?? '',
    loginTime: json["login_time"]?.toString() ?? '',
    logoutTime: json["logout_time"]?.toString() ?? '',
    projects: json["projects"] != null
        ? List<Project>.from(json["projects"].map((x) => Project.fromJson(x)))
        : <Project>[],
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
  final String projectId;
  final String projectName;
  final String customerId;
  final String customerName;
  final String module;
  final List<Task> tasks;

  Project({
    required this.projectId,
    required this.projectName,
    required this.customerId,
    required this.customerName,
    required this.module,
    required this.tasks,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    projectId: json["project_id"]?.toString() ?? '',
    projectName: json["project_name"]?.toString() ?? '',
    customerId: json["customer_id"]?.toString() ?? '',
    customerName: json["customer_name"]?.toString() ?? '',
    module: json["module"]?.toString() ?? '',
    tasks: json["tasks"] != null
        ? List<Task>.from(json["tasks"].map((x) => Task.fromJson(x)))
        : <Task>[],
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
  final String attendanceId;
  final String projectId;
  final String customerId;
  final String assignedTo;
  final String assignedBy;
  final String taskName;
  final String status;
  final String startTime;
  final String endTime;
  final List<String> remarks;
  final String module;
  final String name;
  final String date;
  final String dueDate;
  final String priority;

  Task({
    required this.attendanceId,
    required this.projectId,
    required this.customerId,
    required this.assignedTo,
    required this.assignedBy,
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
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    attendanceId: json["attendance_id"]?.toString() ?? '',
    projectId: json["project_id"]?.toString() ?? '',
    customerId: json["customer_id"]?.toString() ?? '',
    assignedTo: json["assigned_to"]?.toString() ?? '',
    assignedBy: json["assigned_by"]?.toString() ?? '',
    taskName: json["task_name"]?.toString() ?? '',
    status: json["status"]?.toString() ?? '',
    startTime: json["start_time"]?.toString() ?? '',
    endTime: json["end_time"]?.toString() ?? '',
    remarks: json["remarks"] != null 
        ? List<String>.from(json["remarks"].map((x) => x.toString()))
        : <String>[],
    module: json["module"]?.toString() ?? '',
    name: json["name"]?.toString() ?? '',
    date: json["date"]?.toString() ?? '',
    dueDate: json["due_date"]?.toString() ?? '',
    priority: json["priority"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "attendance_id": attendanceId,
    "project_id": projectId,
    "customer_id": customerId,
    "assigned_to": assignedTo,
    "assigned_by": assignedBy,
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
  };

  // Helper method to check if task is completed
  bool get isCompleted => status == "1";
  
  // Helper method to get duration if both times are available
  String? get duration {
    if (startTime.isEmpty || endTime.isEmpty) return null;
    // Add duration calculation logic here if needed
    return '';
  }
}