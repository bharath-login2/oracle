class LeadSourceReportResponse {
  final bool status;
  final String message;
  final List<LeadSourceReportData> data;

  LeadSourceReportResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadSourceReportResponse.fromJson(Map<String, dynamic> json) {
    return LeadSourceReportResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => LeadSourceReportData.fromJson(e))
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

class LeadSourceReportData {
  final String userId;
  final String staffName;
  final int totalCount;
  final List<LeadSourceStatus> statuses;

  LeadSourceReportData({
    required this.userId,
    required this.staffName,
    required this.totalCount,
    required this.statuses,
  });

  factory LeadSourceReportData.fromJson(Map<String, dynamic> json) {
    return LeadSourceReportData(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name'] ?? '',
      totalCount: _parseInt(json['total_count']),
      statuses: (json['statuses'] as List<dynamic>?)
              ?.map((e) => LeadSourceStatus.fromJson(e))
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

class LeadSourceStatus {
  final String leadSourceId;
  final String leadSource;
  final int total;

  LeadSourceStatus({
    required this.leadSourceId,
    required this.leadSource,
    required this.total,
  });

  factory LeadSourceStatus.fromJson(Map<String, dynamic> json) {
    return LeadSourceStatus(
      leadSourceId: json['lead_source_id']?.toString() ?? '',
      leadSource: json['lead_source'] ?? '',
      total: _parseInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lead_source_id': leadSourceId,
      'lead_source': leadSource,
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
