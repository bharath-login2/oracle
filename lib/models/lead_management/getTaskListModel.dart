class GetTaskListResponse {
  final bool status;
  final String message;
  final List<Task> data;

  GetTaskListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetTaskListResponse.fromJson(Map<String, dynamic> json) {
    return GetTaskListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Task.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Task {
  final String id;
  final String workId;
  final String taskName;

  Task({
    required this.id,
    required this.workId,
    required this.taskName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      workId: json['work_id']?.toString() ?? '',
      taskName: json['task_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_id': workId,
      'task_name': taskName,
    };
  }
}