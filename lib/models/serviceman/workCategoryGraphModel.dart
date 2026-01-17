class WorkCategoryModelGraph {
  final bool status;
  final int totalWorkorders;
  final List<WorkCategoryDataGraph> data;
  final String message;

  WorkCategoryModelGraph({
    required this.status,
    required this.totalWorkorders,
    required this.data,
    required this.message,
  });

  factory WorkCategoryModelGraph.fromJson(Map<String, dynamic> json) {
    return WorkCategoryModelGraph(
      status: json['status'] ?? false,
      totalWorkorders: json['total_workorders'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => WorkCategoryDataGraph.fromJson(item))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'total_workorders': totalWorkorders,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class WorkCategoryDataGraph {
  final String workCategoryId;
  final String workCategory;
  final String companyId;
  final int totalUsed;
  final String percentage;

  WorkCategoryDataGraph({
    required this.workCategoryId,
    required this.workCategory,
    required this.companyId,
    required this.totalUsed,
    required this.percentage,
  });

  factory WorkCategoryDataGraph.fromJson(Map<String, dynamic> json) {
    return WorkCategoryDataGraph(
      workCategoryId: json['workCategory_id'] ?? '',
      workCategory: json['work_category'] ?? '',
      companyId: json['company_id'] ?? '',
      totalUsed: json['total_used'] ?? 0,
      percentage: json['percentage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workCategory_id': workCategoryId,
      'work_category': workCategory,
      'company_id': companyId,
      'total_used': totalUsed,
      'percentage': percentage,
    };
  }
}
