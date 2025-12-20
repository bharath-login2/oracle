class QuotationListModel {
  final String? status;
  final String? message;
  final List<QuotationData>? data;

  QuotationListModel({
    this.status,
    this.message,
    this.data,
  });

  factory QuotationListModel.fromJson(Map<String, dynamic> json) {
    return QuotationListModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? List<QuotationData>.from(
              json['data'].map((x) => QuotationData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class QuotationData {
  final String? workorderId;
  final String? customerName;
  final String? date;
  final String? status;
  final String? amount;
  final String? createdBy;
  final String? type;
  QuotationData({
    this.workorderId,
    this.customerName,
    this.date,
    this.status,
    this.amount,
    this.createdBy,
    this.type,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    return QuotationData(
      workorderId: json['workorder_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      amount: json['amount'] ?? '',
      createdBy: json['created_by'] ?? '',
         type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workorder_id': workorderId,
      'customer_name': customerName,
      'date': date,
      'status': status,
      'amount': amount,
      'created_by': createdBy,
         'type': type,
    };
  }
}
