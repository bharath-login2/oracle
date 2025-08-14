class WorkSession {
  final String taskName;
  final String description;
  final String remark;
  final List<Work> works;

  WorkSession({
    required this.taskName,
    required this.description,
    required this.remark,
    required this.works,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      taskName: json['task_name'] ?? '',
      description: json['description'] ?? '',
      remark: json['remarks'] ?? '',
      works: (json['works'] as List<dynamic>?)
          ?.map((work) => Work.fromJson(work))
          .toList() ?? [],
    );
  }
}

class Work {
  final String workedDate;
  final String startTime;
  final String endTime;
  final String duration;

  Work({
    required this.workedDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      workedDate: json['worked_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}

class NotificationSettings {
  final String whatsappNotification;
  final String pushNotification;
  final String onStart;
  final String onSave;
  final String onComplete;
  final List<String> staffIds;
  final List<String> participantIds;
   final List<String> participantNames;

  NotificationSettings({
    required this.whatsappNotification,
    required this.pushNotification,
    required this.onStart,
    required this.onSave,
    required this.onComplete,
    required this.staffIds,
    required this.participantIds,
     required this.participantNames,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      whatsappNotification: json['whatsup_notification']?.toString() ?? '0',
      pushNotification: json['push_notification']?.toString() ?? '0',
      onStart: json['on_start']?.toString() ?? '0',
      onSave: json['on_save']?.toString() ?? '0',
      onComplete: json['on_complete']?.toString() ?? '0',
      staffIds: (json['staff_ids'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      participantIds: (json['participant_ids'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
          participantNames: (json['participant_names'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
    );
  }
}

class AssignedWork {
  final String id;
  final String projectName;
  final String taskName;
  final String taskDescription;
  final String assignedBy;
  final String assignedTo;
  final String assignedToId;
  final String priority;
  final String createdAt;
  final String dueDate;
  final String status;
  final String startStatus;
  final List<WorkSession> workSessions;
  final String clientName;
  final String moduleName;
  final NotificationSettings notification;
    final String unreadCount;
     final String completion;

  AssignedWork({
    required this.id,
    required this.projectName,
    required this.taskName,
    required this.taskDescription,
    required this.assignedBy,
    required this.assignedTo,
    required this.assignedToId,
    required this.priority,
    required this.createdAt,
    required this.dueDate,
    required this.status,
    required this.startStatus,
    required this.workSessions,
    required this.clientName,
    required this.moduleName,
    required this.notification,
    required this.unreadCount,
     required this.completion,
  });

  factory AssignedWork.fromJson(Map<String, dynamic> json) {
    final workSessions = (json['work_sessions'] as List<dynamic>?)
        ?.map((session) => WorkSession.fromJson(session))
        .toList() ?? [];

    return AssignedWork(
      id: json['id']?.toString() ?? '',
      projectName: json['project_name'] ?? '',
      taskName: workSessions.isNotEmpty ? workSessions.first.taskName : '',
      taskDescription: workSessions.isNotEmpty ? workSessions.first.description : '',
      assignedBy: json['assigned_by'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      assignedToId: json['assigned_to_id']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? '',
      startStatus: json['start_status'] ?? '',
      workSessions: workSessions,
      clientName: json['client name'] ?? '',
      moduleName: json['module name'] ?? '',
      notification: NotificationSettings.fromJson(json['notification'] ?? {}),
        unreadCount: json['unread_count'] ?? '',
         completion: json['completion'] ?? '',
    );
  }
}

class AssignedWorkResponse {
  final bool status;
  final List<AssignedWork> data;

  AssignedWorkResponse({
    required this.status,
    required this.data,
  });

  factory AssignedWorkResponse.fromJson(Map<String, dynamic> json) {
    return AssignedWorkResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((work) => AssignedWork.fromJson(work))
          .toList() ?? [],
    );
  }
}