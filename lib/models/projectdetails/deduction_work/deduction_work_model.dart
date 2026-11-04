class DeductionWorkResponse {
  final DeductionWorkData? data;
  final String message;
  final bool status;

  DeductionWorkResponse({
    this.data,
    this.message = '',
    this.status = false,
  });

  factory DeductionWorkResponse.fromJson(Map<String, dynamic> json) {
    return DeductionWorkResponse(
      data: json['data'] != null ? DeductionWorkData.fromJson(json['data']) : null,
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

class DeductionWorkData {
  final List<DeductionWorkRecord> records;
  final String totalAmount;

  DeductionWorkData({
    this.records = const [],
    this.totalAmount = '0.00',
  });

  factory DeductionWorkData.fromJson(Map<String, dynamic> json) {
    return DeductionWorkData(
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => DeductionWorkRecord.fromJson(e as Map<String, dynamic>))
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

class DeductionWorkRecord {
  final String id;
  final String unitNo;
  final String siteLiftNo;
  final String siteLiftName;
  final String unitName;
  final String subId;
  final String projectId;
  final String workName;
  final String workStatus;
  final String file;
  final String amount;
  final String description;

  DeductionWorkRecord({
    this.id = '',
    this.unitNo = '',
    this.siteLiftNo = '',
    this.siteLiftName = '',
    this.unitName = '',
    this.subId = '',
    this.projectId = '',
    this.workName = '',
    this.workStatus = '',
    this.file = '',
    this.amount = '0.00',
    this.description = '',
  });

  factory DeductionWorkRecord.fromJson(Map<String, dynamic> json) {
    return DeductionWorkRecord(
      id: json['id']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      siteLiftNo: json['site_lift_no']?.toString() ?? '',
      siteLiftName: json['site_lift_name']?.toString() ?? '',
      unitName: json['unit_name']?.toString() ?? '',
      subId: json['sub_id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      workName: json['work_name']?.toString() ?? '',
      workStatus: json['work_status']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unit_no': unitNo,
        'site_lift_no': siteLiftNo,
        'site_lift_name': siteLiftName,
        'unit_name': unitName,
        'sub_id': subId,
        'project_id': projectId,
        'work_name': workName,
        'work_status': workStatus,
        'file': file,
        'amount': amount,
        'description': description,
      };

  double get amountValue => double.tryParse(amount) ?? 0.0;
}