// deleted_proforma_invoice_model.dart

class DeletedProformaInvoiceList {
  final bool status;
  final String message;
  final List<DeletedProformaInvoice> data;

  DeletedProformaInvoiceList({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeletedProformaInvoiceList.fromJson(Map<String, dynamic> json) {
    return DeletedProformaInvoiceList(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => DeletedProformaInvoice.fromJson(item))
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
}

class DeletedProformaInvoice {
  final String id;
  final String invoiceNo;
  final String invoiceDate;
  final String customerName;
  final String amount;
  final String status;
  final String staffName;
  final String deletedAt;
  final String deletedBy;

  DeletedProformaInvoice({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.staffName,
    required this.deletedAt,
    required this.deletedBy,
  });

  factory DeletedProformaInvoice.fromJson(Map<String, dynamic> json) {
    return DeletedProformaInvoice(
      id: json['id']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'customer_name': customerName,
      'amount': amount,
      'status': status,
      'staff_name': staffName,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
    };
  }
}
