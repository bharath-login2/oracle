class ProjectTraceResponse {
  final bool status;
  final String message;
  final TraceData data;

  ProjectTraceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectTraceResponse.fromJson(Map<String, dynamic> json) {
    return ProjectTraceResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: TraceData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class TraceData {
  final Map<String, StaffTaskGroup> list;
  final String totalDuration;
  final int totalRecords;

  TraceData({
    required this.list,
    required this.totalDuration,
    required this.totalRecords,
  });

  factory TraceData.fromJson(Map<String, dynamic> json) {
    final listMap = <String, StaffTaskGroup>{};
    
    if (json['list'] is Map<String, dynamic>) {
      (json['list'] as Map<String, dynamic>).forEach((key, value) {
        listMap[key] = StaffTaskGroup.fromJson(value);
      });
    }
    
    return TraceData(
      list: listMap,
      totalDuration: json['total_duration'] ?? '',
      totalRecords: json['total_records'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((key, value) => MapEntry(key, value.toJson())),
      'total_duration': totalDuration,
      'total_records': totalRecords,
    };
  }
}

class StaffTaskGroup {
  final List<Task> tasks;
  final int totalSeconds;
  final String totalDuration;

  StaffTaskGroup({
    required this.tasks,
    required this.totalSeconds,
    required this.totalDuration,
  });

  factory StaffTaskGroup.fromJson(Map<String, dynamic> json) {
    return StaffTaskGroup(
      tasks: (json['tasks'] as List?)
          ?.map((e) => Task.fromJson(e))
          .toList() ?? [],
      totalSeconds: json['total_seconds'] ?? 0,
      totalDuration: json['total_duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'total_seconds': totalSeconds,
      'total_duration': totalDuration,
    };
  }
}

class Task {
  final String title;
  final String taskId;
  final String taskName;
  final String totalDuration;
  final String status;
  final String startTime;
  final String endTime;
  final String createdAt;
  final String userId;
  final String? remarks;
  final String staffName;

  Task({
    required this.title,
    required this.taskId,
    required this.taskName,
    required this.totalDuration,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.userId,
    this.remarks,
    required this.staffName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      taskId: json['task_id']?.toString() ?? '',
      taskName: json['task_name'] ?? '',
      totalDuration: json['total_duration'] ?? '',
      status: json['status']?.toString() ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      createdAt: json['created_at'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      remarks: json['remarks'],
      staffName: json['staff_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'task_id': taskId,
      'task_name': taskName,
      'total_duration': totalDuration,
      'status': status,
      'start_time': startTime,
      'end_time': endTime,
      'created_at': createdAt,
      'user_id': userId,
      'remarks': remarks,
      'staff_name': staffName,
    };
  }
}
