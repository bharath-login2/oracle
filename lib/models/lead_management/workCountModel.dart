// work_count_model.dart

class WorksCountModel {
  final bool status;
  final String message;
  final WorksCountData data;

  WorksCountModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WorksCountModel.fromJson(Map<String, dynamic> json) {
    return WorksCountModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: WorksCountData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
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

class WorksCountData {
  final StatusCount pending;
  final StatusCount completedToday;

  WorksCountData({
    required this.pending,
    required this.completedToday,
  });

  factory WorksCountData.fromJson(Map<String, dynamic> json) {
    return WorksCountData(
      pending: StatusCount.fromJson(json['pending'] as Map<String, dynamic>? ?? {}),
      completedToday: StatusCount.fromJson(json['completed_today'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending.toJson(),
      'completed_today': completedToday.toJson(),
    };
  }
}

class StatusCount {
  final int taskCount;
  final int workCount;
  final List<StaffWorkCount> staffList;

  StatusCount({
    required this.taskCount,
    required this.workCount,
    required this.staffList,
  });

  factory StatusCount.fromJson(Map<String, dynamic> json) {
    // Handle empty staff list entries
    final staffListJson = json['staff_list'] as List<dynamic>? ?? [];
    final List<StaffWorkCount> staffList = [];

    for (var item in staffListJson) {
      if (item is Map<String, dynamic>) {
        // Check if staff_id is not empty
        final staffId = item['staff_id']?.toString() ?? '';
        final staffName = item['staff_name']?.toString() ?? '';
        
        // Only add if both staff_id and staff_name are not empty
        if (staffId.isNotEmpty && staffName.isNotEmpty) {
          staffList.add(StaffWorkCount.fromJson(item));
        }
      }
    }

    return StatusCount(
      taskCount: (json['task_count'] as int?) ?? 0,
      workCount: (json['work_count'] as int?) ?? 0,
      staffList: staffList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_count': taskCount,
      'work_count': workCount,
      'staff_list': staffList.map((staff) => staff.toJson()).toList(),
    };
  }
}

class StaffWorkCount {
  final String staffId;
  final String staffName;
  final String taskCount;
  final String workCount;

  StaffWorkCount({
    required this.staffId,
    required this.staffName,
    required this.taskCount,
    required this.workCount,
  });

  factory StaffWorkCount.fromJson(Map<String, dynamic> json) {
    return StaffWorkCount(
      staffId: json['staff_id']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      taskCount: json['task_count']?.toString() ?? '0',
      workCount: json['work_count']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'staff_name': staffName,
      'task_count': taskCount,
      'work_count': workCount,
    };
  }
}