class WorkManagementResponse {
  final WorkData? data;
  final String message;
  final bool status;

  WorkManagementResponse({
    this.data,
    required this.message,
    required this.status,
  });

  factory WorkManagementResponse.fromJson(Map<String, dynamic> json) {
    return WorkManagementResponse(
      data: json['data'] != null ? WorkData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class WorkData {
  final int recordsTotal;
  final int recordsFiltered;
  final List<WorkRecord> records;

  WorkData({
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.records,
  });

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      recordsTotal: json['recordsTotal'] ?? 0,
      recordsFiltered: json['recordsFiltered'] ?? 0,
      records: json['records'] != null
          ? List<WorkRecord>.from(
              json['records'].map((x) => WorkRecord.fromJson(x)),
            )
          : [],
    );
  }
}

class WorkRecord {
  final String id;
  final String projectId;
  final String title;
  final String taskType;
  final String category;
  final String priority;
  final String dueDate;
  final String startDate;
  final String assignedTo;
  final String assignedFrom;
  final String createdAt;
  final String status;
  final String endTime;
  final String projectName;
  final String staffName;
  final String assignedName;
  final String assignedWorkId;
  final String wrkPriority;
  final String customerName;
  final String unitNo;
  final String siteLiftName;
  final String stageName;
  final List<String> taskNames;
  final bool hasAttachments;
  final bool isOverdue;

  WorkRecord({
    required this.id,
    required this.projectId,
    required this.title,
    required this.taskType,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.startDate,
    required this.assignedTo,
    required this.assignedFrom,
    required this.createdAt,
    required this.status,
    required this.endTime,
    required this.projectName,
    required this.staffName,
    required this.assignedName,
    required this.assignedWorkId,
    required this.wrkPriority,
    required this.customerName,
    required this.unitNo,
    required this.siteLiftName,
    required this.stageName,
    required this.taskNames,
    required this.hasAttachments,
    required this.isOverdue,
  });

  factory WorkRecord.fromJson(Map<String, dynamic> json) {
    return WorkRecord(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      title: json['title'] ?? '',
      taskType: json['task_type'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      dueDate: json['due_date'] ?? '',
      startDate: json['start_date'] ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
      assignedFrom: json['assigned_from']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
      endTime: json['end_time'] ?? '',
      projectName: json['project_name'] ?? '',
      staffName: json['staff_name'] ?? '',
      assignedName: json['assigned_name'] ?? '',
      assignedWorkId: json['assigned_work_id']?.toString() ?? '',
      wrkPriority: json['wrk_priority'] ?? '',
      customerName: json['customer_name'] ?? '',
      unitNo: json['unit_no'] ?? '',
      siteLiftName: json['site_lift_name'] ?? '',
      stageName: json['stage_name'] ?? '',
      taskNames: json['task_names'] != null
          ? List<String>.from(json['task_names'].map((x) => x.toString()))
          : [],
      hasAttachments: json['has_attachments'] == 1 || json['has_attachments'] == true,
      isOverdue: json['is_overdue'] == 1 || json['is_overdue'] == true,
    );
  }

  /// Displays primary task name or falls back to title/id
  String get displayTitle {
    if (taskNames.isNotEmpty && taskNames.first.isNotEmpty) {
      return taskNames.first;
    }
    return title.isNotEmpty ? title : 'Work #${id}';
  }

  /// Formats date string to YYYY-MM-DD
  String get formattedDueDate {
    if (dueDate.isEmpty) return 'N/A';
    return dueDate.split(' ').first;
  }
}