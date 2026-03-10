class LeadSourceReportOntapModel {
  final bool status;
  final String message;
  final LeadSourceOntapData data;

  LeadSourceReportOntapModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadSourceReportOntapModel.fromJson(Map<String, dynamic> json) {
    return LeadSourceReportOntapModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: LeadSourceOntapData.fromJson(json['data'] ?? {}),
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

class LeadSourceOntapData {
  final List<LeadSourceStaffDetail> details;
  final int totalCount;

  LeadSourceOntapData({
    required this.details,
    required this.totalCount,
  });

  factory LeadSourceOntapData.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];

    return LeadSourceOntapData(
      details: detailsList
          .map((item) => LeadSourceStaffDetail.fromJson(item))
          .toList(),
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

class LeadSourceStaffDetail {
  final String userId;
  final String staffName;
  final int total;

  LeadSourceStaffDetail({
    required this.userId,
    required this.staffName,
    required this.total,
  });

  factory LeadSourceStaffDetail.fromJson(Map<String, dynamic> json) {
    return LeadSourceStaffDetail(
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
