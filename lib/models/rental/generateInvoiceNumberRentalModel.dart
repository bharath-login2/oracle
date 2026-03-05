class GenerateInvoiceNumberRentalModel {
  final bool status;
  final String message;
  final InvoiceData? data;

  GenerateInvoiceNumberRentalModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory GenerateInvoiceNumberRentalModel.fromJson(Map<String, dynamic> json) {
    return GenerateInvoiceNumberRentalModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? InvoiceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'GenerateInvoiceNumberRentalModel(status: $status, message: $message, data: $data)';
  }
}

class InvoiceData {
  final String invoiceNo;

  InvoiceData({
    required this.invoiceNo,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoiceNo: json['invoice_no'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_no': invoiceNo,
    };
  }

  @override
  String toString() {
    return 'InvoiceData(invoiceNo: $invoiceNo)';
  }
}
