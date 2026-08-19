class ProjectDashboardCountModel {
  final bool status;
  final String message;
  final ProjectDashboardData? data;

  ProjectDashboardCountModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProjectDashboardCountModel.fromJson(Map<String, dynamic> json) {
    return ProjectDashboardCountModel(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null && json["data"] is Map<String, dynamic>
          ? ProjectDashboardData.fromJson(json["data"])
          : null,
    );
  }
}

class ProjectDashboardData {
  final String username;
  final String designation;
  final String fromDate;
  final String toDate;
  final ProjectCounts? projectCounts;

  ProjectDashboardData({
    required this.username,
    required this.designation,
    required this.fromDate,
    required this.toDate,
    this.projectCounts,
  });

  factory ProjectDashboardData.fromJson(Map<String, dynamic> json) {
    return ProjectDashboardData(
      username: json["username"]?.toString() ?? "",
      designation: json["designation"]?.toString() ?? "",
      fromDate: json["from_date"]?.toString() ?? "",
      toDate: json["to_date"]?.toString() ?? "",
      projectCounts: json["project_counts"] != null &&
              json["project_counts"] is Map<String, dynamic>
          ? ProjectCounts.fromJson(json["project_counts"])
          : null,
    );
  }
}

class ProjectCounts {
  final String upcoming;
  final String running;
  final String completed;
  final String all;

  ProjectCounts({
    required this.upcoming,
    required this.running,
    required this.completed,
    required this.all,
  });

  factory ProjectCounts.fromJson(Map<String, dynamic> json) {
    return ProjectCounts(
      upcoming: json["upcoming"]?.toString() ?? "0",
      running: json["running"]?.toString() ?? "0",
      completed: json["completed"]?.toString() ?? "0",
      all: json["all"]?.toString() ?? "0",
    );
  }

  int get upcomingInt => int.tryParse(upcoming) ?? 0;
  int get runningInt => int.tryParse(running) ?? 0;
  int get completedInt => int.tryParse(completed) ?? 0;
  int get allInt => int.tryParse(all) ?? 0;
}
