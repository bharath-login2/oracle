class LeadSourceReportModel {
  final bool status;
  final String message;
  final LeadSourceData data;

  LeadSourceReportModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadSourceReportModel.fromJson(Map<String, dynamic> json) {
    return LeadSourceReportModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: LeadSourceData.fromJson(json['data'] ?? {}),
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

class LeadSourceData {
  final List<LeadSourceDetail> details;
  final int totalCount;

  LeadSourceData({
    required this.details,
    required this.totalCount,
  });

  factory LeadSourceData.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];

    return LeadSourceData(
      details:
          detailsList.map((item) => LeadSourceDetail.fromJson(item)).toList(),
      totalCount: json['total_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((detail) => detail.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class LeadSourceDetail {
  final String leadSourceId;
  final String leadSource;
  final int total;

  LeadSourceDetail({
    required this.leadSourceId,
    required this.leadSource,
    required this.total,
  });

  factory LeadSourceDetail.fromJson(Map<String, dynamic> json) {
    return LeadSourceDetail(
      leadSourceId: json['lead_source_id']?.toString() ?? '',
      leadSource: json['lead_source'] ?? '',
      total: json['total'] ?? 0,
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
