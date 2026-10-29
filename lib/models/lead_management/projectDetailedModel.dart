double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

class ProjectDetailedResponse {
  final bool status;
  final String message;
  final ProjectDetailedData? data;

  ProjectDetailedResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProjectDetailedResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDetailedResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ProjectDetailedData.fromJson(json['data'])
          : null,
    );
  }
}

class ProjectUnit {
  final String id;
  final String unitNo;

  ProjectUnit({required this.id, required this.unitNo});

  factory ProjectUnit.fromJson(Map<String, dynamic> json) {
    return ProjectUnit(
      id: json['id']?.toString() ?? '',
      // API sends trailing spaces (e.g. "Irin kurian 2 "), so trim
      unitNo: json['unit_no']?.toString().trim() ?? '',
    );
  }
}

class ProjectDetailedData {
  final String id;
  final String clientId;
  final String projectName;
  final String projectId;
  final String location;
  final String locationArea;
  final String workStatus; // NEW
  final String cctvId;
  final String clientName;
  final String contact1;
  final String address1;
  final String totalEstimateAmount;
  final String startingDate;
  final String completionDate;

  // NEW: money fields (API returns these as numbers, not strings)
  final double totalProjectCost;
  final double receivedFromClient;
  final double totalExpensePayment;
  final double totalPurchasePayment;

  // NEW: units
  final List<ProjectUnit> units;
  final int totalUnits;

  final String totalWorked;
  final String unassignedWorks;
  final String companyIssue;
  final String companyIssueCount;
  final String clientIssue;
  final String clientIssueCount;
  final String paymentPending;
  final String paymentPendingCount;
  final String generalIssue;
  final String generalIssueCount;
  final String elevationImage;
  final String planImage;

  ProjectDetailedData({
    required this.id,
    required this.clientId,
    required this.projectName,
    required this.projectId,
    required this.location,
    required this.locationArea,
    required this.workStatus,
    required this.cctvId,
    required this.clientName,
    required this.contact1,
    required this.address1,
    required this.totalEstimateAmount,
    required this.startingDate,
    required this.completionDate,
    required this.totalProjectCost,
    required this.receivedFromClient,
    required this.totalExpensePayment,
    required this.totalPurchasePayment,
    required this.units,
    required this.totalUnits,
    required this.totalWorked,
    required this.unassignedWorks,
    required this.companyIssue,
    required this.companyIssueCount,
    required this.clientIssue,
    required this.clientIssueCount,
    required this.paymentPending,
    required this.paymentPendingCount,
    required this.generalIssue,
    required this.generalIssueCount,
    required this.elevationImage,
    required this.planImage,
  });

  factory ProjectDetailedData.fromJson(Map<String, dynamic> json) {
    final unitsJson = json['units'];
    final units = unitsJson is List
        ? unitsJson
            .whereType<Map<String, dynamic>>()
            .map(ProjectUnit.fromJson)
            .toList()
        : <ProjectUnit>[];

    return ProjectDetailedData(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      locationArea: json['location_area']?.toString() ?? '',
      workStatus: json['work_status']?.toString() ?? '',
      cctvId: json['cctv_id']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? '',
      contact1: json['contact1']?.toString() ?? '',
      address1: json['address1']?.toString() ?? '',
      totalEstimateAmount: json['total_estimate_amount']?.toString() ?? '0',
      startingDate: json['starting_date']?.toString() ?? '',
      completionDate: json['completion_date']?.toString() ?? '',
      totalProjectCost: _toDouble(json['total_project_cost']),
      receivedFromClient: _toDouble(json['received_from_client']),
      totalExpensePayment: _toDouble(json['total_expense_payment']),
      totalPurchasePayment: _toDouble(json['total_purchase_payment']),
      units: units,
      // Fall back to list length if the API omits total_units
      totalUnits: json['total_units'] != null
          ? _toInt(json['total_units'])
          : units.length,
      totalWorked: json['total_worked']?.toString() ?? '0',
      unassignedWorks: json['unassigned_works']?.toString() ?? '0',
      companyIssue: json['company_issue']?.toString() ?? '',
      companyIssueCount: json['company_issue_count']?.toString() ?? '0',
      clientIssue: json['client_issue']?.toString() ?? '',
      clientIssueCount: json['client_issue_count']?.toString() ?? '0',
      paymentPending: json['payment_pending']?.toString() ?? '',
      paymentPendingCount: json['payment_pending_count']?.toString() ?? '0',
      generalIssue: json['general_issue']?.toString() ?? '',
      generalIssueCount: json['general_issue_count']?.toString() ?? '0',
      elevationImage: json['elevation_image']?.toString() ?? '',
      planImage: json['plan_image']?.toString() ?? '',
    );
  }
}
