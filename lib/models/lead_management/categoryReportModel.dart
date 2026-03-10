class CategoryReportModel {
  final bool status;
  final String message;
  final CategoryData data;

  CategoryReportModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryReportModel.fromJson(Map<String, dynamic> json) {
    bool parsedStatus = false;
    if (json['status'] == true ||
        json['status'] == 'true' ||
        json['status'] == 1 ||
        json['status'] == 'success' ||
        json['status'] == 200) {
      parsedStatus = true;
    }
    return CategoryReportModel(
      status: parsedStatus,
      message: json['message']?.toString() ?? '',
      data: CategoryData.fromJson(json['data'] ?? {}),
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

class CategoryData {
  final List<CategoryDetail> details;
  final int totalCount;

  CategoryData({
    required this.details,
    required this.totalCount,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];

    int parsedTotalCount = 0;
    if (json['total_count'] != null) {
      if (json['total_count'] is int) {
        parsedTotalCount = json['total_count'];
      } else if (json['total_count'] is String) {
        parsedTotalCount = int.tryParse(json['total_count']) ?? 0;
      }
    }

    return CategoryData(
      details:
          detailsList.map((item) => CategoryDetail.fromJson(item)).toList(),
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

class CategoryDetail {
  final int leadCategoryId;
  final String leadCategory;
  final int total;

  CategoryDetail({
    required this.leadCategoryId,
    required this.leadCategory,
    required this.total,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    int parsedLeadCategoryId = 0;
    if (json['lead_category_id'] != null) {
      if (json['lead_category_id'] is int) {
        parsedLeadCategoryId = json['lead_category_id'];
      } else if (json['lead_category_id'] is String) {
        parsedLeadCategoryId = int.tryParse(json['lead_category_id']) ?? 0;
      }
    }

    int parsedTotal = 0;
    if (json['total'] != null) {
      if (json['total'] is int) {
        parsedTotal = json['total'];
      } else if (json['total'] is String) {
        parsedTotal = int.tryParse(json['total']) ?? 0;
      }
    }

    return CategoryDetail(
      leadCategoryId: parsedLeadCategoryId,
      leadCategory: json['lead_category']?.toString() ?? '',
      total: parsedTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lead_category_id': leadCategoryId,
      'lead_category': leadCategory,
      'total': total,
    };
  }
}
