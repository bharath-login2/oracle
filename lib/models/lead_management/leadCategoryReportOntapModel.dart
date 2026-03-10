class LeadCategoryReportOntapModel {
  final bool status;
  final String message;
  final LeadCategoryOntapData data;

  LeadCategoryReportOntapModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadCategoryReportOntapModel.fromJson(Map<String, dynamic> json) {
    bool parsedStatus = false;
    if (json['status'] == true ||
        json['status'] == 'true' ||
        json['status'] == 1 ||
        json['status'] == 'success' ||
        json['status'] == 200) {
      parsedStatus = true;
    }
    return LeadCategoryReportOntapModel(
      status: parsedStatus,
      message: json['message']?.toString() ?? '',
      data: LeadCategoryOntapData.fromJson(json['data'] ?? {}),
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

class LeadCategoryOntapData {
  final List<LeadCategoryStaffDetail> details;
  final int totalCount;

  LeadCategoryOntapData({
    required this.details,
    required this.totalCount,
  });

  factory LeadCategoryOntapData.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];

    int parsedTotalCount = 0;
    if (json['total_count'] != null) {
      if (json['total_count'] is int) {
        parsedTotalCount = json['total_count'];
      } else if (json['total_count'] is String) {
        parsedTotalCount = int.tryParse(json['total_count']) ?? 0;
      }
    }

    return LeadCategoryOntapData(
      details: detailsList
          .map((item) => LeadCategoryStaffDetail.fromJson(item))
          .toList(),
      totalCount: parsedTotalCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((detail) => detail.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class LeadCategoryStaffDetail {
  final String userId;
  final String staffName;
  final int total;

  LeadCategoryStaffDetail({
    required this.userId,
    required this.staffName,
    required this.total,
  });

  factory LeadCategoryStaffDetail.fromJson(Map<String, dynamic> json) {
    int parsedTotal = 0;
    if (json['total'] != null) {
      if (json['total'] is int) {
        parsedTotal = json['total'];
      } else if (json['total'] is String) {
        parsedTotal = int.tryParse(json['total']) ?? 0;
      }
    }

    return LeadCategoryStaffDetail(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      total: parsedTotal,
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
