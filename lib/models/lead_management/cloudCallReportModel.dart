class CloudCallReportModel {
  final bool? status;
  final String? message;
  final List<CallReportData>? data;

  CloudCallReportModel({
    this.status,
    this.message,
    this.data,
  });

  factory CloudCallReportModel.fromJson(Map<String, dynamic> json) {
    return CloudCallReportModel(
      status: json['status'],
      message: json['message']?.toString(),
      data: json['data'] != null
          ? List<CallReportData>.from(
              json['data'].map((x) => CallReportData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class CallReportData {
  final String? userId;
  final String? staffName;
  final String? totalCalls;
  final String? totalConnected;
  final String? totalDuration;

  CallReportData({
    this.userId,
    this.staffName,
    this.totalCalls,
    this.totalConnected,
    this.totalDuration,
  });

  factory CallReportData.fromJson(Map<String, dynamic> json) {
    return CallReportData(
      userId: json['user_id']?.toString(),
      staffName: json['staff_name']?.toString(),
      totalCalls: json['total_calls']?.toString(),
      totalConnected: json['total_connected']?.toString(),
      totalDuration: json['total_duration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'total_calls': totalCalls,
      'total_connected': totalConnected,
      'total_duration': totalDuration,
    };
  }
}
