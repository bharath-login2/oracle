class WarrantyPeriodResponse {
  final bool status;
  final String message;
  final List<WarrantyPeriodItem> data;

  WarrantyPeriodResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WarrantyPeriodResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'];
    List<WarrantyPeriodItem> items = [];
    if (list != null && list is List) {
      items = list.map((e) => WarrantyPeriodItem.fromJson(e)).toList();
    }
    return WarrantyPeriodResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: items,
    );
  }
}

class WarrantyPeriodItem {
  final String id;
  final String periodName;
  final String companyId;

  WarrantyPeriodItem({
    required this.id,
    required this.periodName,
    required this.companyId,
  });

  factory WarrantyPeriodItem.fromJson(Map<String, dynamic> json) {
    return WarrantyPeriodItem(
      id: json['id']?.toString() ?? '',
      periodName: json['period_name']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
    );
  }
}

class LiabilityPeriodResponse {
  final bool status;
  final String message;
  final List<LiabilityPeriodItem> data;

  LiabilityPeriodResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LiabilityPeriodResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'];
    List<LiabilityPeriodItem> items = [];
    if (list != null && list is List) {
      items = list.map((e) => LiabilityPeriodItem.fromJson(e)).toList();
    }
    return LiabilityPeriodResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: items,
    );
  }
}

class LiabilityPeriodItem {
  final String id;
  final String periodName;
  final String companyId;

  LiabilityPeriodItem({
    required this.id,
    required this.periodName,
    required this.companyId,
  });

  factory LiabilityPeriodItem.fromJson(Map<String, dynamic> json) {
    return LiabilityPeriodItem(
      id: json['id']?.toString() ?? '',
      periodName: json['period_name']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
    );
  }
}

class ProjectStatusListResponse {
  final bool status;
  final String message;
  final List<ProjectStatusItem> data;

  ProjectStatusListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectStatusListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'];
    List<ProjectStatusItem> items = [];
    if (list != null && list is List) {
      items = list.map((e) => ProjectStatusItem.fromJson(e)).toList();
    }
    return ProjectStatusListResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: items,
    );
  }
}

class ProjectStatusItem {
  final String statusName;
  final String slugName;
  final String companyId;

  ProjectStatusItem({
    required this.statusName,
    required this.slugName,
    required this.companyId,
  });

  factory ProjectStatusItem.fromJson(Map<String, dynamic> json) {
    return ProjectStatusItem(
      statusName: json['status_name']?.toString() ?? '',
      slugName: json['slug_name']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
    );
  }
}
