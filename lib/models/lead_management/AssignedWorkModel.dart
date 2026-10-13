class SupportingStaff {
  final String id;
  final String staffName;

  SupportingStaff({
    required this.id,
    required this.staffName,
  });

  factory SupportingStaff.fromJson(Map<String, dynamic> json) {
    return SupportingStaff(
      id: json['id']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
    );
  }
}

class WorkSession {
  final String projectId;
  final String taskId;
  final String activityId;
  final String taskName;
  final String description;
  final String remark;
  final String status;
  final String count;
  final String totalHours;
  final String lastUpdatedTime;
  final List<SupportingStaff> supportingStaff;
  final List<Work> works;

  WorkSession({
    required this.projectId,
    required this.taskId,
    this.activityId = '',
    required this.taskName,
    required this.description,
    required this.remark,
    required this.status,
    required this.count,
    required this.totalHours,
    required this.lastUpdatedTime,
    this.supportingStaff = const [],
    required this.works,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      projectId: json['project_id'] ?? '',
      taskId: json['task_id'] ?? '',
      activityId: json['activity_id']?.toString() ?? '',
      taskName: json['task_name'] ?? '',
      description: json['description'] ?? '',
      remark: json['remarks'] ?? '',
      status: json['status'] ?? '',
      count: json['count']?.toString() ?? '',
      totalHours: json['total_hours']?.toString() ?? '',
      lastUpdatedTime: json['last_updated_time'] ?? '',
      supportingStaff: (json['supporting_staff'] as List<dynamic>?)
              ?.map((staff) => SupportingStaff.fromJson(staff))
              .toList() ??
          [],
      works: (json['works'] as List<dynamic>?)
              ?.map((work) => Work.fromJson(work))
              .toList() ??
          [],
    );
  }
}

class Work {
  final String workedDate;
  final String startTime;
  final String endTime;
  final String duration;
  final List<String> remarks;

  Work({
    required this.workedDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.remarks,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    List<String> parsedRemarks = [];

    if (json['remarks'] != null) {
      if (json['remarks'] is List) {
        parsedRemarks = (json['remarks'] as List)
            .map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
      } else if (json['remarks'] is String) {
        String remarksStr = json['remarks'] as String;
        if (remarksStr.trim().isNotEmpty) {
          parsedRemarks = remarksStr
              .split(RegExp(r'[,\n]'))
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();
        }
      }
    }

    return Work(
      workedDate: json['worked_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      remarks: parsedRemarks,
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
              .toList() ??
          [],
      participantIds: (json['participant_ids'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      participantNames: (json['participant_names'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
    );
  }
}

class AssignedWork {
  final String total;
  final String totalTask;
  final String id;
  final String projectId;
  final String projectName;
  final String taskId;
  final String taskName;
  final String taskDescription;
  final String assignedBy;
  final String assignedTo;
  final String assignedToId;
  final String priority;
  final String createdAt;
  final String startDate;
  final String dueDate;
  final String status;
  final String startStatus;
  final String lastWorkTime;
  final String totalHours;
  final List<WorkSession> workSessions;
  final String clientName;
  final String clientId;
  final String moduleName;
  final String siteLiftName;
  final String siteLiftNo;
  final String siteLiftId;
  final String unitId;
  final String unitNo;
  final List<SupportingStaff> supportingStaff;
  final NotificationSettings notification;
  final String unreadCount;
  final String completion;

  AssignedWork({
    required this.total,
    required this.totalTask,
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.assignedBy,
    required this.assignedTo,
    required this.assignedToId,
    required this.priority,
    required this.createdAt,
    this.startDate = '',
    required this.dueDate,
    required this.status,
    required this.startStatus,
    required this.lastWorkTime,
    this.totalHours = '',
    required this.workSessions,
    required this.clientName,
    required this.clientId,
    required this.moduleName,
    this.siteLiftName = '',
    this.siteLiftNo = '',
    this.siteLiftId = '',
    this.unitId = '',
    this.unitNo = '',
    this.supportingStaff = const [],
    required this.notification,
    required this.unreadCount,
    required this.completion,
  });

  factory AssignedWork.fromJson(Map<String, dynamic> json) {
    final workSessions = (json['work_sessions'] as List<dynamic>?)
            ?.map((session) => WorkSession.fromJson(session))
            .toList() ??
        [];

    final supportingStaffList = (json['supporting_staff'] as List<dynamic>?)
            ?.map((staff) => staff is Map<String, dynamic>
                ? SupportingStaff.fromJson(staff)
                : SupportingStaff(id: '', staffName: staff.toString()))
            .toList() ??
        (json['supporting_staffs'] as List<dynamic>?)
            ?.map((staff) => staff is Map<String, dynamic>
                ? SupportingStaff.fromJson(staff)
                : SupportingStaff(id: '', staffName: staff.toString()))
            .toList() ??
        (json['supporting_staff_names'] as List<dynamic>?)
            ?.map((staff) => SupportingStaff(id: '', staffName: staff.toString()))
            .toList() ??
        workSessions.expand((s) => s.supportingStaff).toList();

    return AssignedWork(
      total: json['total']?.toString() ?? '',
      totalTask: json['total_tasks']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      projectName: json['project_name'] ?? '',
      projectId: json['project_id'] ?? '',
      taskId: workSessions.isNotEmpty ? workSessions.first.taskId : '',
      taskName: workSessions.isNotEmpty ? workSessions.first.taskName : '',
      taskDescription:
          workSessions.isNotEmpty ? workSessions.first.description : '',
      assignedBy: json['assigned_by'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      assignedToId: json['assigned_to_id']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      startDate: json['start_date']?.toString() ?? '',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? '',
      startStatus: json['start_status'] ?? '',
      lastWorkTime: json['last_work_time'] ?? '',
      totalHours: json['total_hours']?.toString() ?? '',
      workSessions: workSessions,
      clientName: json['client name'] ?? '',
      clientId: json['client_id'] ?? '',
      moduleName: json['module name'] ?? '',
      siteLiftName: json['site_lift_name']?.toString() ?? '',
      siteLiftNo: json['site_lift_no']?.toString() ?? '',
      siteLiftId: json['site_lift_id']?.toString() ?? json['site_lift_no']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      supportingStaff: supportingStaffList,
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
              .toList() ??
          [],
    );
  }
}
