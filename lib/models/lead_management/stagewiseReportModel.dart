class StagewiseReportModel {
  final bool status;
  final String message;
  final StagewiseData data;

  StagewiseReportModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StagewiseReportModel.fromJson(Map<String, dynamic> json) {
    return StagewiseReportModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: StagewiseData.fromJson(json['data'] ?? {}),
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

class StagewiseData {
  final List<StagewiseDetail> details;
  final int totalCount;

  StagewiseData({
    required this.details,
    required this.totalCount,
  });

  factory StagewiseData.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];

    return StagewiseData(
      details:
          detailsList.map((item) => StagewiseDetail.fromJson(item)).toList(),
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

class StagewiseDetail {
  final String callResultId;
  final String callResult;
  final int total;

  StagewiseDetail({
    required this.callResultId,
    required this.callResult,
    required this.total,
  });

  factory StagewiseDetail.fromJson(Map<String, dynamic> json) {
    return StagewiseDetail(
      callResultId: json['call_result_id']?.toString() ?? '',
      callResult: json['call_result'] ?? '',
      total: json['total'] ?? 0,
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
