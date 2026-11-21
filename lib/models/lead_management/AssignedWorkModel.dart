import 'dart:convert';

List<String> _parseAttachmentStringList(dynamic raw) {
  final List<String> result = [];
  if (raw == null) return result;
  if (raw is List) {
    for (var item in raw) {
      if (item == null) continue;
      final str = item.toString().trim();
      if (str.isNotEmpty) result.add(str);
    }
  } else if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty) {
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            for (var item in decoded) {
              if (item != null && item.toString().trim().isNotEmpty) {
                result.add(item.toString().trim());
              }
            }
          }
        } catch (_) {
          result.add(trimmed);
        }
      } else {
        result.addAll(
          trimmed
              .split(RegExp(r'[,\n]'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }
    }
  } else {
    final str = raw.toString().trim();
    if (str.isNotEmpty) result.add(str);
  }
  return result;
}

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
  final String workCompletePercent;
  final List<SupportingStaff> supportingStaff;
  final List<Work> works;
  final List<String> attachments;
  final List<String> attachmentIds;
  final List<String> attachmentFileIds;

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
    this.workCompletePercent = '',
    this.supportingStaff = const [],
    required this.works,
    this.attachments = const [],
    this.attachmentIds = const [],
    this.attachmentFileIds = const [],
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    List<String> parsedSessionAttachments = [];
    List<String> parsedSessionAttachmentIds = _parseAttachmentStringList(
        json['attachment_ids'] ?? json['attachment_id']);
    List<String> parsedSessionAttachmentFileIds = _parseAttachmentStringList(
        json['attachment_file_ids'] ?? json['attachment_file_id']);

    final rawSessionAttachments = json['attachments'] ?? json['attachment'];
    if (rawSessionAttachments != null) {
      if (rawSessionAttachments is List) {
        for (var item in rawSessionAttachments) {
          if (item == null) continue;
          if (item is String && item.trim().isNotEmpty) {
            parsedSessionAttachments.add(item.trim());
          } else if (item is Map) {
            final url = item['url'] ??
                item['file'] ??
                item['attachment'] ??
                item['path'] ??
                item['link'];
            if (url != null && url.toString().trim().isNotEmpty) {
              parsedSessionAttachments.add(url.toString().trim());
              if (parsedSessionAttachmentIds.length <
                  parsedSessionAttachments.length) {
                final idVal =
                    (item['attachment_id'] ?? item['id'] ?? '').toString().trim();
                parsedSessionAttachmentIds.add(idVal);
              }
              if (parsedSessionAttachmentFileIds.length <
                  parsedSessionAttachments.length) {
                final fileIdVal = (item['attachment_file_id'] ??
                        item['file_id'] ??
                        '')
                    .toString()
                    .trim();
                parsedSessionAttachmentFileIds.add(fileIdVal);
              }
            }
          } else {
            final str = item.toString().trim();
            if (str.isNotEmpty) parsedSessionAttachments.add(str);
          }
        }
      } else if (rawSessionAttachments is String) {
        final trimmed = rawSessionAttachments.trim();
        if (trimmed.isNotEmpty) {
          if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            try {
              final decoded = jsonDecode(trimmed);
              if (decoded is List) {
                for (var item in decoded) {
                  if (item != null && item.toString().trim().isNotEmpty) {
                    parsedSessionAttachments.add(item.toString().trim());
                  }
                }
              }
            } catch (_) {
              parsedSessionAttachments.add(trimmed);
            }
          } else {
            parsedSessionAttachments.addAll(
              trimmed
                  .split(RegExp(r'[,\n]'))
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            );
          }
        }
      }
    }

    final parsedWorks = (json['works'] as List<dynamic>?)
            ?.map((work) => Work.fromJson(work))
            .toList() ??
        [];

    String parsedWorkCompletePercent = (json['work_complete_percent'] ??
            json['completion_percent'] ??
            json['work_completion_percent'] ??
            json['complete_percent'] ??
            json['completion'] ??
            '')
        .toString()
        .trim();

    if (parsedWorkCompletePercent.isEmpty && parsedWorks.isNotEmpty) {
      final lastWorkWithPercent = parsedWorks.lastWhere(
        (w) => w.completionPercent.isNotEmpty,
        orElse: () => parsedWorks.last,
      );
      if (lastWorkWithPercent.completionPercent.isNotEmpty) {
        parsedWorkCompletePercent = lastWorkWithPercent.completionPercent;
      }
    }

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
      workCompletePercent: parsedWorkCompletePercent,
      supportingStaff: (json['supporting_staff'] as List<dynamic>?)
              ?.map((staff) => SupportingStaff.fromJson(staff))
              .toList() ??
          [],
      works: parsedWorks,
      attachments: parsedSessionAttachments,
      attachmentIds: parsedSessionAttachmentIds,
      attachmentFileIds: parsedSessionAttachmentFileIds,
    );
  }
}

class Work {
  final String workedDate;
  final String startTime;
  final String endTime;
  final String duration;
  final List<String> remarks;
  final String completionPercent;
  final List<String> attachments;
  final List<String> attachmentIds;
  final List<String> attachmentFileIds;

  Work({
    required this.workedDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.remarks,
    this.completionPercent = '',
    this.attachments = const [],
    this.attachmentIds = const [],
    this.attachmentFileIds = const [],
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

    List<String> parsedAttachments = [];
    List<String> parsedAttachmentIds = _parseAttachmentStringList(
        json['attachment_ids'] ?? json['attachment_id']);
    List<String> parsedAttachmentFileIds = _parseAttachmentStringList(
        json['attachment_file_ids'] ?? json['attachment_file_id']);

    final rawAttachments = json['attachments'] ?? json['attachment'];
    if (rawAttachments != null) {
      if (rawAttachments is List) {
        for (var item in rawAttachments) {
          if (item == null) continue;
          if (item is String && item.trim().isNotEmpty) {
            parsedAttachments.add(item.trim());
          } else if (item is Map) {
            final url = item['url'] ??
                item['file'] ??
                item['attachment'] ??
                item['path'] ??
                item['link'];
            if (url != null && url.toString().trim().isNotEmpty) {
              parsedAttachments.add(url.toString().trim());
              if (parsedAttachmentIds.length < parsedAttachments.length) {
                final idVal =
                    (item['attachment_id'] ?? item['id'] ?? '').toString().trim();
                parsedAttachmentIds.add(idVal);
              }
              if (parsedAttachmentFileIds.length < parsedAttachments.length) {
                final fileIdVal = (item['attachment_file_id'] ??
                        item['file_id'] ??
                        '')
                    .toString()
                    .trim();
                parsedAttachmentFileIds.add(fileIdVal);
              }
            }
          } else {
            final str = item.toString().trim();
            if (str.isNotEmpty) parsedAttachments.add(str);
          }
        }
      } else if (rawAttachments is String) {
        final trimmed = rawAttachments.trim();
        if (trimmed.isNotEmpty) {
          if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            try {
              final decoded = jsonDecode(trimmed);
              if (decoded is List) {
                for (var item in decoded) {
                  if (item != null && item.toString().trim().isNotEmpty) {
                    parsedAttachments.add(item.toString().trim());
                  }
                }
              }
            } catch (_) {
              parsedAttachments.add(trimmed);
            }
          } else {
            parsedAttachments.addAll(
              trimmed
                  .split(RegExp(r'[,\n]'))
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            );
          }
        }
      }
    }

    String parsedCompletionPercent = (json['completion_percent'] ??
            json['work_complete_percent'] ??
            json['work_completion_percent'] ??
            json['complete_percent'] ??
            json['completion'] ??
            json['completion_percentage'] ??
            '')
        .toString()
        .trim();

    return Work(
      workedDate: json['worked_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      remarks: parsedRemarks,
      completionPercent: parsedCompletionPercent,
      attachments: parsedAttachments,
      attachmentIds: parsedAttachmentIds,
      attachmentFileIds: parsedAttachmentFileIds,
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
  final String workType;
  final String staffType;
  final String phNo;
  final List<String> attachments;
  final List<String> attachmentIds;
  final List<String> attachmentFileIds;

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
    this.workType = '',
    this.staffType = '',
    this.phNo = '',
    this.attachments = const [],
    this.attachmentIds = const [],
    this.attachmentFileIds = const [],
  });

  factory AssignedWork.fromJson(Map<String, dynamic> json) {
    List<String> parsedRootAttachments = [];
    List<String> parsedRootAttachmentIds = _parseAttachmentStringList(
        json['attachment_ids'] ?? json['attachment_id']);
    List<String> parsedRootAttachmentFileIds = _parseAttachmentStringList(
        json['attachment_file_ids'] ?? json['attachment_file_id']);

    final rawRootAttachments =
        json['attachments'] ?? json['attachment'] ?? json['files'] ?? json['file'];
    if (rawRootAttachments != null) {
      if (rawRootAttachments is List) {
        for (var item in rawRootAttachments) {
          if (item == null) continue;
          if (item is String && item.trim().isNotEmpty) {
            parsedRootAttachments.add(item.trim());
          } else if (item is Map) {
            final url = item['url'] ??
                item['file'] ??
                item['attachment'] ??
                item['path'] ??
                item['link'];
            if (url != null && url.toString().trim().isNotEmpty) {
              parsedRootAttachments.add(url.toString().trim());
              if (parsedRootAttachmentIds.length <
                  parsedRootAttachments.length) {
                final idVal =
                    (item['attachment_id'] ?? item['id'] ?? '').toString().trim();
                parsedRootAttachmentIds.add(idVal);
              }
              if (parsedRootAttachmentFileIds.length <
                  parsedRootAttachments.length) {
                final fileIdVal = (item['attachment_file_id'] ??
                        item['file_id'] ??
                        '')
                    .toString()
                    .trim();
                parsedRootAttachmentFileIds.add(fileIdVal);
              }
            }
          } else {
            final str = item.toString().trim();
            if (str.isNotEmpty) parsedRootAttachments.add(str);
          }
        }
      } else if (rawRootAttachments is String) {
        final trimmed = rawRootAttachments.trim();
        if (trimmed.isNotEmpty) {
          if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            try {
              final decoded = jsonDecode(trimmed);
              if (decoded is List) {
                for (var item in decoded) {
                  if (item != null && item.toString().trim().isNotEmpty) {
                    parsedRootAttachments.add(item.toString().trim());
                  }
                }
              }
            } catch (_) {
              parsedRootAttachments.add(trimmed);
            }
          } else {
            parsedRootAttachments.addAll(
              trimmed
                  .split(RegExp(r'[,\n]'))
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            );
          }
        }
      }
    }

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
      workType: (json['work_type'] ?? json['workType'] ?? '').toString(),
      staffType: (json['staff_type_name'] ??
              json['staff_type'] ??
              json['staffTypeName'] ??
              json['staffType'] ??
              '')
          .toString(),
      phNo: (json['phone_number'] ?? json['phone_number'] ?? '').toString(),
      completion: (json['completion'] ??
              json['work_complete_percent'] ??
              json['completion_percent'] ??
              '')
          .toString(),
      attachments: parsedRootAttachments,
      attachmentIds: parsedRootAttachmentIds,
      attachmentFileIds: parsedRootAttachmentFileIds,
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
