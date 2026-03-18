class StagewiseReportResponse {
  final bool status;
  final String message;
  final List<StagewiseReportData> data;

  StagewiseReportResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StagewiseReportResponse.fromJson(Map<String, dynamic> json) {
    return StagewiseReportResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => StagewiseReportData.fromJson(e))
              .toList() ??
          [],
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

class StagewiseReportData {
  final String userId;
  final String staffName;
  final int totalCount;
  final List<StageStatus> statuses;

  StagewiseReportData({
    required this.userId,
    required this.staffName,
    required this.totalCount,
    required this.statuses,
  });

  factory StagewiseReportData.fromJson(Map<String, dynamic> json) {
    return StagewiseReportData(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name'] ?? '',
      totalCount: _parseInt(json['total_count']),
      statuses: (json['statuses'] as List<dynamic>?)
              ?.map((e) => StageStatus.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'total_count': totalCount,
      'statuses': statuses.map((e) => e.toJson()).toList(),
    };
  }
}

class StageStatus {
  final String callResultId;
  final String callResult;
  final int total;

  StageStatus({
    required this.callResultId,
    required this.callResult,
    required this.total,
  });

  factory StageStatus.fromJson(Map<String, dynamic> json) {
    return StageStatus(
      callResultId: json['call_result_id']?.toString() ?? '',
      callResult: json['call_result'] ?? '',
      total: _parseInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'call_result_id': callResultId,
      'call_result': callResult,
      'total': total,
    };
  }
}

// Helper function to parse int from dynamic values
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}
