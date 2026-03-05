
class PaymentReportRentalModel {
  final bool status;
  final String message;
  final PaymentReportData? data;

  PaymentReportRentalModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory PaymentReportRentalModel.fromJson(Map<String, dynamic> json) {
    return PaymentReportRentalModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? PaymentReportData.fromJson(json['data'] as Map<String, dynamic>)
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
    return 'PaymentReportRentalModel(status: $status, message: $message, data: $data)';
  }
}

class PaymentReportData {
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final List<PaymentReportItem> list;

  PaymentReportData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.list,
  });

  factory PaymentReportData.fromJson(Map<String, dynamic> json) {
    return PaymentReportData(
      draw: json['draw'] as int? ?? 0,
      recordsTotal: json['recordsTotal'] as int? ?? 0,
      recordsFiltered: json['recordsFiltered'] as int? ?? 0,
      list: (json['list'] as List<dynamic>?)
              ?.map(
                  (e) => PaymentReportItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'draw': draw,
      'recordsTotal': recordsTotal,
      'recordsFiltered': recordsFiltered,
      'list': list.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'PaymentReportData(draw: $draw, recordsTotal: $recordsTotal, recordsFiltered: $recordsFiltered, listCount: ${list.length})';
  }
}

class PaymentReportItem {
  final int slNo;
  final String rentIssueId;
  final String invoiceNo;
  final String paymentDate;
  final String customerName;
  final String paymentMethod;
  final String products;
  final double totalAmount;
  final double balanceAmount;
  final String paymentStatus;

  PaymentReportItem({
    required this.slNo,
    required this.rentIssueId,
    required this.invoiceNo,
    required this.paymentDate,
    required this.customerName,
    required this.paymentMethod,
    required this.products,
    required this.totalAmount,
    required this.balanceAmount,
    required this.paymentStatus,
  });

  factory PaymentReportItem.fromJson(Map<String, dynamic> json) {
    return PaymentReportItem(
      slNo: json['sl_no'] as int? ?? 0,
      rentIssueId: json['rent_issue_id']?.toString() ?? '',
      invoiceNo: json['invoice_no'] as String? ?? '',
      paymentDate: json['payment_date'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      products: json['products'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sl_no': slNo,
      'rent_issue_id': rentIssueId,
      'invoice_no': invoiceNo,
      'payment_date': paymentDate,
      'customer_name': customerName,
      'payment_method': paymentMethod,
      'products': products,
      'total_amount': totalAmount,
      'balance_amount': balanceAmount,
      'payment_status': paymentStatus,
    };
  }
}
