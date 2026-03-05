// get_deleted_invoice_list_model.dart

class GetDeletedInvoiceList {
  final bool status;
  final String message;
  final List<DeletedInvoice> data;

  GetDeletedInvoiceList({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetDeletedInvoiceList.fromJson(Map<String, dynamic> json) {
    return GetDeletedInvoiceList(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => DeletedInvoice.fromJson(item))
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
    return 'GetDeletedInvoiceList{status: $status, message: $message, data: $data}';
  }
}

class DeletedInvoice {
  final String id;
  final String invoiceNo;
  final String invoiceDate;
  final String customerName;
  final String staffName;
  final String totalAmount;
  final String paidAmount;
  final String balance;
  final String paymentStatus;
  final String deletedAt;
  final String deletedBy;
  final String isHidden;

  DeletedInvoice({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.customerName,
    required this.staffName,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.paymentStatus,
    required this.deletedAt,
    required this.deletedBy,
    required this.isHidden,
  });

  factory DeletedInvoice.fromJson(Map<String, dynamic> json) {
    return DeletedInvoice(
      id: json['id']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
      paidAmount: json['paid_amount']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      isHidden: json['is_hidden']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'customer_name': customerName,
      'staff_name': staffName,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance': balance,
      'payment_status': paymentStatus,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
      'is_hidden': isHidden,
    };
  }
}
