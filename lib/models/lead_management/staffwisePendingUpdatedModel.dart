class StaffwisePendingUpdatedModel {
  final bool status;
  final List<Summary> summary;
  final Count count;
  StaffwisePendingUpdatedModel({
    required this.status,
    required this.summary,
    required this.count,
  });

  factory StaffwisePendingUpdatedModel.fromJson(Map<String, dynamic> json) {
    return StaffwisePendingUpdatedModel(
      status: json['status'] as bool? ?? false,
      summary: (json['summary'] as List<dynamic>? ?? [])
          .map((summaryJson) =>
              Summary.fromJson(summaryJson as Map<String, dynamic>))
          .toList(),
      count: Count.fromJson(json['count'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'summary': summary.map((summary) => summary.toJson()).toList(),
      'count': count.toJson(),
    };
  }
}

class Summary {
  final String userId;
  final String staffName;
  final List<Project> projects;

  Summary({
    required this.userId,
    required this.staffName,
    required this.projects,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      userId: (json['user_id'] ?? '').toString(),
      staffName: (json['staff_name'] ?? '').toString(),
      projects: (json['projects'] as List<dynamic>? ?? [])
          .map((projectJson) =>
              Project.fromJson(projectJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'projects': projects.map((project) => project.toJson()).toList(),
    };
  }
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

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: (json['project_id'] ?? '').toString(),
      projectName: (json['project_name'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      module: (json['module'] ?? '').toString(),
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'customer_id': customerId,
      'customer_name': customerName,
      'module': module,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }
}

class Task {
  final String workId;
  final String workDetailsId;
  final String taskName;
  final String status;
  final String assignedBy;
  final String assignedTo;
  final String priority;
  final String dueDate;
  final List<String> remarks;

  Task({
    required this.workId,
    required this.workDetailsId,
    required this.taskName,
    required this.status,
    required this.assignedBy,
    required this.assignedTo,
    required this.priority,
    required this.dueDate,
    required this.remarks,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      workId: (json['work_id'] ?? '').toString(),
      workDetailsId: (json['work_details_id'] ?? '').toString(),
      taskName: (json['task_name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      assignedBy: (json['assigned_by'] ?? '').toString(),
      assignedTo: (json['assigned_to'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
      dueDate: (json['due_date'] ?? '').toString(),
      remarks: (json['remarks'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work_id': workId,
      'work_details_id': workDetailsId,
      'task_name': taskName,
      'status': status,
      'assigned_by': assignedBy,
      'assigned_to': assignedTo,
      'priority': priority,
      'due_date': dueDate,
      'remarks': remarks,
    };
  }
}

class Count {
  final String workCount;
  final String taskCount;

  Count({
    required this.workCount,
    required this.taskCount,
  });

  factory Count.fromJson(Map<String, dynamic> json) {
    return Count(
      workCount: (json['work_count'] ?? '0').toString(),
      taskCount: (json['task_count'] ?? '0').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work_count': workCount,
      'task_count': taskCount,
    };
  }
}
