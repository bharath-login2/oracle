// deleted_receipt_list_model.dart

class DeletedReceiptList {
  final bool status;
  final String message;
  final List<DeletedReceipt> data;

  DeletedReceiptList({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeletedReceiptList.fromJson(Map<String, dynamic> json) {
    return DeletedReceiptList(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => DeletedReceipt.fromJson(item))
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
    return 'DeletedReceiptList{status: $status, message: $message, data: $data}';
  }
}

class DeletedReceipt {
  final String id;
  final String receiptNo;
  final String receiptDate;
  final String invoiceNo;
  final String customerName;
  final String amount;
  final String collectedBy;
  final String createdBy;
  final String deletedAt;
  final String deletedBy;
  final String verification;
  final String type;

  DeletedReceipt({
    required this.id,
    required this.receiptNo,
    required this.receiptDate,
    required this.invoiceNo,
    required this.customerName,
    required this.amount,
    required this.collectedBy,
    required this.createdBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.verification,
    required this.type,
  });

  factory DeletedReceipt.fromJson(Map<String, dynamic> json) {
    return DeletedReceipt(
      id: json['id']?.toString() ?? '',
      receiptNo: json['receipt_no']?.toString() ?? '',
      receiptDate: json['receipt_date']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      collectedBy: json['collected_by']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      verification: json['verification']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_no': receiptNo,
      'receipt_date': receiptDate,
      'invoice_no': invoiceNo,
      'customer_name': customerName,
      'amount': amount,
      'collected_by': collectedBy,
      'created_by': createdBy,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
      'verification': verification,
      'type': type,
    };
  }
}
