class ExtraWorkResponse {
  final ExtraWorkData? data;
  final String message;
  final bool status;

  ExtraWorkResponse({
    this.data,
    this.message = '',
    this.status = false,
  });

  factory ExtraWorkResponse.fromJson(Map<String, dynamic> json) {
    return ExtraWorkResponse(
      data: json['data'] != null ? ExtraWorkData.fromJson(json['data']) : null,
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
        'message': message,
        'status': status,
      };
}

class ExtraWorkData {
  final List<ExtraWorkRecord> records;
  final String totalAmount;

  ExtraWorkData({
    this.records = const [],
    this.totalAmount = '0.00',
  });

  factory ExtraWorkData.fromJson(Map<String, dynamic> json) {
    return ExtraWorkData(
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => ExtraWorkRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() => {
        'records': records.map((e) => e.toJson()).toList(),
        'total_amount': totalAmount,
      };

  double get totalAmountValue => double.tryParse(totalAmount) ?? 0.0;
}

class ExtraWorkRecord {
  final String id;
  final String projectId;
  final String workName;
  final String amount;
  final String description;
  final String createdAt;
  final String staffName;
  final String workStatus;
  final String unitNo;
  final String siteLiftNo;

  ExtraWorkRecord({
    this.id = '',
    this.projectId = '',
    this.workName = '',
    this.amount = '0.00',
    this.description = '',
    this.createdAt = '',
    this.staffName = '',
    this.workStatus = '',
    this.unitNo = '',
    this.siteLiftNo = '',
  });

  factory ExtraWorkRecord.fromJson(Map<String, dynamic> json) {
    return ExtraWorkRecord(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      workName: json['work_name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      workStatus: json['work_status']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      siteLiftNo: json['site_lift_no']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'work_name': workName,
        'amount': amount,
        'description': description,
        'created_at': createdAt,
        'staff_name': staffName,
        'work_status': workStatus,
        'unit_no': unitNo,
        'site_lift_no': siteLiftNo,
      };

  double get amountValue => double.tryParse(amount) ?? 0.0;

  /// Parses "2026-10-23 12:45:01" into a DateTime (null if invalid).
  DateTime? get createdAtDate => DateTime.tryParse(createdAt);
}
