class CallStatusReportResponse {
  final bool status;
  final String message;
  final List<CallStatusReportData> data;

  CallStatusReportResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CallStatusReportResponse.fromJson(Map<String, dynamic> json) {
    return CallStatusReportResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CallStatusReportData.fromJson(e))
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

class CallStatusReportData {
  final String userId;
  final String staffName;
  final List<CallStatus> statuses;
  final int totalCount;

  CallStatusReportData({
    required this.userId,
    required this.staffName,
    required this.statuses,
    required this.totalCount,
  });

  factory CallStatusReportData.fromJson(Map<String, dynamic> json) {
    return CallStatusReportData(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name'] ?? '',
      statuses: (json['statuses'] as List<dynamic>?)
              ?.map((e) => CallStatus.fromJson(e))
              .toList() ??
          [],
      totalCount: _parseInt(json['total_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'statuses': statuses.map((e) => e.toJson()).toList(),
      'total': totalCount,
    };
  }
}

class CallStatus {
  final String callResponseId;
  final String callResponse;
  final int total;

  CallStatus({
    required this.callResponseId,
    required this.callResponse,
    required this.total,
  });

  factory CallStatus.fromJson(Map<String, dynamic> json) {
    return CallStatus(
      callResponseId: json['call_response_id']?.toString() ?? '',
      callResponse: json['call_response'] ?? '',
      total: _parseInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'call_response_id': callResponseId,
      'call_response': callResponse,
      'total': total,
    };
  }
}

// Helper function to parse int from dynamic values
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
