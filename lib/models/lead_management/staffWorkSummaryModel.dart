import 'dart:convert';

StaffWorkSummery staffWorkSummeryFromJson(String str) =>
    StaffWorkSummery.fromJson(json.decode(str));

String staffWorkSummeryToJson(StaffWorkSummery data) =>
    json.encode(data.toJson());

class StaffWorkSummery {
  String status;
  String message;
  List<StaffWork> data;

  StaffWorkSummery({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StaffWorkSummery.fromJson(Map<String, dynamic> json) =>
      StaffWorkSummery(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<StaffWork>.from(
                json["data"].map((x) => StaffWork.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class StaffWork {
  String userId;
  String staffName;
  String loginTime;
  String logoutTime;
  List<Project> projects;

  StaffWork({
    required this.userId,
    required this.staffName,
    required this.loginTime,
    required this.logoutTime,
    required this.projects,
  });

  factory StaffWork.fromJson(Map<String, dynamic> json) => StaffWork(
        userId: json["user_id"]?.toString() ?? "",
        staffName: json["staff_name"] ?? "",
        loginTime: json["login_time"] ?? "",
        logoutTime: json["logout_time"] ?? "",
        projects: json["projects"] != null
            ? List<Project>.from(
                (json["projects"] as List).map((x) => Project.fromJson(x)))
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
  String projectName;
  String customerName;
  String moduleName;
  List<Task> tasks;

  Project({
    required this.projectName,
      required this.customerName,
    required this.moduleName,
    required this.tasks,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        projectName: json["project_name"] ?? "",
         customerName: json["customer_name"] ?? "",
         moduleName: json["module"] ?? "",
        tasks: json["tasks"] != null
            ? List<Task>.from(
                (json["tasks"] as List).map((x) => Task.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "project_name": projectName,
          "customer_name": customerName,
         "module": moduleName,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  String taskName;
   String status;
  String startTime;
  String endTime;
  List<String> remarks;

  Task({
    required this.taskName,
     required this.status,
    required this.startTime,
    required this.endTime,
    required this.remarks,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskName: json["task_name"] ?? "",
           status: json["status"] ?? "",
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        remarks: json["remarks"] != null
            ? List<String>.from(json["remarks"])
            : [],
      );

  Map<String, dynamic> toJson() => {
        "task_name": taskName,
          "status": status,
        "start_time": startTime,
        "end_time": endTime,
        "remarks": remarks,
      };
}

