class StagewiseReportOntapModel {
  final bool status;
  final String message;
  final StagewiseOntapData data;

  StagewiseReportOntapModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StagewiseReportOntapModel.fromJson(Map<String, dynamic> json) {
    return StagewiseReportOntapModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: StagewiseOntapData.fromJson(json['data'] ?? {}),
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

class StagewiseOntapData {
  final List<StaffDetail> details;
  final int totalCount;

  StagewiseOntapData({
    required this.details,
    required this.totalCount,
  });

  factory StagewiseOntapData.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];

    return StagewiseOntapData(
      details: detailsList.map((item) => StaffDetail.fromJson(item)).toList(),
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

class StaffDetail {
  final String userId;
  final String staffName;
  final int total;

  StaffDetail({
    required this.userId,
    required this.staffName,
    required this.total,
  });

  factory StaffDetail.fromJson(Map<String, dynamic> json) {
    return StaffDetail(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name'] ?? '',
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'total': total,
    };
  }
}
