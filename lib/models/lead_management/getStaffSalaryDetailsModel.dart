class GetStaffSalaryDetailsModel {
  final String message;
  final SalaryData data;
  final bool status;

  GetStaffSalaryDetailsModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory GetStaffSalaryDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetStaffSalaryDetailsModel(
      message: json['message']?.toString() ?? '',
      data: json['data'] != null 
          ? SalaryData.fromJson(json['data']) 
          : SalaryData.empty(),
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
      'status': status,
    };
  }
}

class SalaryData {
  final String currentSalary;
  final List<SalaryHistory> history;

  SalaryData({
    required this.currentSalary,
    required this.history,
  });

  factory SalaryData.fromJson(Map<String, dynamic> json) {
    return SalaryData(
      currentSalary: json['current_salary']?.toString() ?? '0',
      history: json['history'] != null
          ? List<SalaryHistory>.from(
              json['history'].map((x) => SalaryHistory.fromJson(x)))
          : [],
    );
  }

  factory SalaryData.empty() {
    return SalaryData(
      currentSalary: '0',
      history: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_salary': currentSalary,
      'history': List<dynamic>.from(history.map((x) => x.toJson())),
    };
  }
  double get parsedCurrentSalary => double.tryParse(currentSalary) ?? 0.0;
}

class SalaryHistory {
  final String id;
  final String amount;
  final String fromDate;
  final String toDate;
    final String remark;
  final String createdBy;
  final String createdAt;
  final String updatedBy;
  final String updatedAt;
  final String createdByName;
  final String updatedByName;

  SalaryHistory({
    required this.id,
    required this.amount,
    required this.fromDate,
    required this.toDate,
    required this.remark,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.createdByName,
    required this.updatedByName,
  });

  factory SalaryHistory.fromJson(Map<String, dynamic> json) {
    return SalaryHistory(
      id: json['id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      createdByName: json['created_by_name']?.toString() ?? '',
      updatedByName: json['updated_by_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'from_date': fromDate,
      'to_date': toDate,
      'remark': remark,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'created_by_name': createdByName,
      'updated_by_name': updatedByName,
    };
  }

  
}