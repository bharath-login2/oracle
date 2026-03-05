// get_gst_deleted_model.dart

class GetGstDeletedModel {
  final bool status;
  final String message;
  final List<GstDeletedInvoice> data;

  GetGstDeletedModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetGstDeletedModel.fromJson(Map<String, dynamic> json) {
    return GetGstDeletedModel(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => GstDeletedInvoice.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'GetGstDeletedModel{status: $status, message: $message, data: $data}';
  }
}

class GstDeletedInvoice {
  final String id;
  final String invoiceNo;
  final String invoiceDate;
  final String customerName;
  final String paymentMode;
  final String totalAmount;
  final String? paymentStatus;
  final String deletedBy;
  final String deletedAt;

  GstDeletedInvoice({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.customerName,
    required this.paymentMode,
    required this.totalAmount,
    this.paymentStatus,
    required this.deletedBy,
    required this.deletedAt,
  });

  factory GstDeletedInvoice.fromJson(Map<String, dynamic> json) {
    return GstDeletedInvoice(
      id: json['id']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString(),
      deletedBy: json['deleted_by']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'customer_name': customerName,
      'payment_mode': paymentMode,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'deleted_by': deletedBy,
      'deleted_at': deletedAt,
    };
  }


}