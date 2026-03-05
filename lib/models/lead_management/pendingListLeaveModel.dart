class PendingLeaveListModel {
  final dynamic status;
  final int count;
  final List<PendingLeaveData> data;

  PendingLeaveListModel({
    required this.status,
    required this.count,
    required this.data,
  });

  factory PendingLeaveListModel.fromJson(Map<String, dynamic> json) {
    return PendingLeaveListModel(
      status: json['status'],
      count: json['count'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map(
              (item) => PendingLeaveData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class PendingLeaveData {
  final String id;
  final String userId;
  final String leaveType;
  final String leaveDates;
  final String dayType;
  final String reason;
  final String status;
  final String createdAt;
  final String noOfDays;
  final String staffName;
  final String? fromDate;
  final String? toDate;
  final String? remarks;

  PendingLeaveData({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.leaveDates,
    required this.dayType,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.noOfDays,
    required this.staffName,
    this.fromDate,
    this.toDate,
    this.remarks,
  });

  factory PendingLeaveData.fromJson(Map<String, dynamic> json) {
    return PendingLeaveData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      leaveType: json['leave_type']?.toString() ?? '',
      leaveDates: json['leave_dates']?.toString() ?? '',
      dayType: json['day_type']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      noOfDays: json['no_of_days']?.toString() ?? '0',
      staffName: json['staff_name']?.toString() ?? '',
      fromDate: json['from_date']?.toString(),
      toDate: json['to_date']?.toString(),
      remarks: json['remarks']?.toString() ?? json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'leave_type': leaveType,
      'leave_dates': leaveDates,
      'day_type': dayType,
      'reason': reason,
      'status': status,
      'created_at': createdAt,
      'no_of_days': noOfDays,
      'staff_name': staffName,
      'from_date': fromDate,
      'to_date': toDate,
      'remarks': remarks,
    };
  }
}
