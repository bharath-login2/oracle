class CategoryReportTableModel {
  final List<StaffCategoryData>? data;
  final bool? status;
  final String? message;

  CategoryReportTableModel({
    this.data,
    this.status,
    this.message,
  });

  factory CategoryReportTableModel.fromJson(Map<String, dynamic> json) {
    return CategoryReportTableModel(
      data: json['data'] != null
          ? List<StaffCategoryData>.from(
              json['data'].map((x) => StaffCategoryData.fromJson(x)))
          : null,
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((x) => x.toJson()).toList(),
      'status': status,
      'message': message,
    };
  }
}

class StaffCategoryData {
  final String? userId;
  final String? staffName;
  final List<CategoryStatus>? statuses;
  final int? totalCount;

  StaffCategoryData({
    this.userId,
    this.staffName,
    this.statuses,
    this.totalCount,
  });

  factory StaffCategoryData.fromJson(Map<String, dynamic> json) {
    return StaffCategoryData(
      userId: json['user_id']?.toString(),
      staffName: json['staff_name'],
      statuses: json['statuses'] != null
          ? List<CategoryStatus>.from(
              json['statuses'].map((x) => CategoryStatus.fromJson(x)))
          : null,
      totalCount: json['total_count'] != null 
          ? int.tryParse(json['total_count'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'statuses': statuses?.map((x) => x.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class CategoryStatus {
  final dynamic leadCategoryId; 
  final String? leadCategory;
  final String? total; 
  int? get totalAsInt => total != null ? int.tryParse(total!) : null;

  CategoryStatus({
    this.leadCategoryId,
    this.leadCategory,
    this.total,
  });

  factory CategoryStatus.fromJson(Map<String, dynamic> json) {
    return CategoryStatus(
      leadCategoryId: json['lead_category_id'],
      leadCategory: json['lead_category'],
      total: json['total']?.toString(),
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