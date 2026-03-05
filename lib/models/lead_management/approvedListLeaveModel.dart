class ApprovedLeaveListModel {
  final dynamic status;
  final int count;
  final List<ApprovedLeaveData> data;

  ApprovedLeaveListModel({
    required this.status,
    required this.count,
    required this.data,
  });

  factory ApprovedLeaveListModel.fromJson(Map<String, dynamic> json) {
    return ApprovedLeaveListModel(
      status: json['status'],
      count: json['count'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((item) =>
              ApprovedLeaveData.fromJson(item as Map<String, dynamic>))
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

class ApprovedLeaveData {
  final String id;
  final String userId;
  final String leaveType;
  final String leaveDates;
  final String approvedDates;
  final String dayType;
  final String reason;
  final String status;
  final String createdAt;
  final String noOfDays;
  final String staffName;
  final String approvedBy;
  final String? fromDate;
  final String? toDate;
  final String? remarks;

  ApprovedLeaveData({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.leaveDates,
    required this.approvedDates,
    required this.dayType,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.noOfDays,
    required this.staffName,
    required this.approvedBy,
    this.fromDate,
    this.toDate,
    this.remarks,
  });

  factory ApprovedLeaveData.fromJson(Map<String, dynamic> json) {
    return ApprovedLeaveData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      leaveType: json['leave_type']?.toString() ?? '',
      leaveDates: json['leave_dates']?.toString() ?? '',
      approvedDates: json['approved_dates']?.toString() ?? '',
      dayType: json['day_type']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      noOfDays: json['no_of_days']?.toString() ?? '0',
      staffName: json['staff_name']?.toString() ?? '',
      approvedBy: json['approved_by']?.toString() ?? '',
      fromDate: json['from_date']?.toString(),
      toDate: json['to_date']?.toString(),
      remarks: json['remarks']?.toString() ?? json['reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'leave_type': leaveType,
      'leave_dates': leaveDates,
      'approved_dates': approvedDates,
      'day_type': dayType,
      'reason': reason,
      'status': status,
      'created_at': createdAt,
      'no_of_days': noOfDays,
      'staff_name': staffName,
      'approved_by': approvedBy,
      'from_date': fromDate,
      'to_date': toDate,
      'remarks': remarks,
    };
  }
}
