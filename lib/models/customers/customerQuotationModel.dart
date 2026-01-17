class CustomerwiseQuotationList {
  final bool status;
  final String message;
  final List<QuotationData> data;

  CustomerwiseQuotationList({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerwiseQuotationList.fromJson(Map<String, dynamic> json) {
    return CustomerwiseQuotationList(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => QuotationData.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class QuotationData {
  final String id;
  final String quoteId;
  final String customerId;
  final String workorderId;
  final String enquiryDate;
  final String totalAmount;
  final String approvalStatus;
  final String type;
  final String customerName;
  final String isSend;
  final String createdby;

  QuotationData({
    required this.id,
    required this.quoteId,
    required this.customerId,
    required this.workorderId,
    required this.enquiryDate,
    required this.totalAmount,
    required this.approvalStatus,
    required this.type,
    required this.customerName,
    required this.isSend,
    required this.createdby,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    return QuotationData(
      id: json['id']?.toString() ?? '',
      quoteId: json['quote_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      workorderId: json['workorder_id']?.toString() ?? '',
      enquiryDate: json['enquiry_date']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      approvalStatus: json['approval_status']?.toString() ?? '0',
      type: json['type']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      isSend: json['is_send']?.toString() ?? 'N',
      createdby: json['createdby']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote_id': quoteId,
      'customer_id': customerId,
      'workorder_id': workorderId,
      'enquiry_date': enquiryDate,
      'total_amount': totalAmount,
      'approval_status': approvalStatus,
      'type': type,
      'customer_name': customerName,
      'is_send': isSend,
      'createdby': createdby,
    };
  }
}
