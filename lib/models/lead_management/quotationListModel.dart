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
   final String? quotationMainId;
  final String? customerName;
    final String? customerId;
  final String? date;
  final String? status;
  final String? amount;
  final String? createdBy;
  final String? type;
  final String? isSend;
  QuotationData({
    this.workorderId,
      this.quotationMainId,
    this.customerName,
      this.customerId,
    this.date,
    this.status,
    this.amount,
    this.createdBy,
    this.type,
    this.isSend,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    return QuotationData(
      workorderId: json['workorder_id'] ?? '',
        quotationMainId: json['quotation_main_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerId: json['customer_id'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      amount: json['amount'] ?? '',
      createdBy: json['created_by'] ?? '',
         type: json['type'] ?? '',
          isSend: json['is_send'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workorder_id': workorderId,
       'quotation_main_id': quotationMainId,
      'customer_name': customerName,
        'customer_id': customerId,
      'date': date,
      'status': status,
      'amount': amount,
      'created_by': createdBy,
         'type': type,
          'is_send': isSend,
    };
  }
}
