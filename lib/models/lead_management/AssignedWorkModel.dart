class AssignedWork {
  final String id;
  final String projectName;
  final String taskName;
   final String taskDescription;
  final String assignedBy;
  final String assignedTo;
  final String priority;
  final String createdAt;
  final String dueDate;
  final String status;

  AssignedWork({
    required this.id,
    required this.projectName,
    required this.taskName,
    required this.taskDescription,
    required this.assignedBy,
    required this.assignedTo,
    required this.priority,
    required this.createdAt,
    required this.dueDate,
    required this.status,
  });

  factory AssignedWork.fromJson(Map<String, dynamic> json) {
    return AssignedWork(
      id: json['id'] ?? '',
      projectName: json['project_name'] ?? '',
      taskName: json['task_name'] ?? '',
         taskDescription: json['description'] ?? '',
      assignedBy: json['assigned_by'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      priority: json['priority'] ?? '',
      createdAt: json['created_at'] ?? '',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
