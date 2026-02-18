class StaffwiseWorkDataCountModel {
  final bool status;
  final String message;
  final List<WorkData> data;

  StaffwiseWorkDataCountModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StaffwiseWorkDataCountModel.fromJson(Map<String, dynamic> json) {
    return StaffwiseWorkDataCountModel(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => WorkData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkData {
  final String totalWorkingDays;
  final String workedDays;
  final String leaveDays;

  WorkData({
    required this.totalWorkingDays,
    required this.workedDays,
    required this.leaveDays,
  });

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      totalWorkingDays: json['total_working_days'] as String,
      workedDays: json['worked_days'] as String,
      leaveDays: json['leave_days'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_working_days': totalWorkingDays,
      'worked_days': workedDays,
      'leave_days': leaveDays,
    };
  }
}