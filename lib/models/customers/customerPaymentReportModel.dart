class CustomerPaymentReportModel {
  final List<CustomerPaymentData>? data;
  final bool? status;
  final String? message;

  CustomerPaymentReportModel({
    this.data,
    this.status,
    this.message,
  });

  factory CustomerPaymentReportModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentReportModel(
      data: json['data'] != null
          ? List<CustomerPaymentData>.from(
              json['data'].map((x) => CustomerPaymentData.fromJson(x)))
          : null,
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((x) => x.toJson()).toList(),
      'status': status,
      'message': message,
    };
  }
}

class CustomerPaymentData {
  final String? accountId;
  final String? accountName;
  final String? paymentHidden;
  final String? hiddenBy;
  final String? hiddenByName;
  final String? hiddenDate;
  final dynamic pendingAmount;
  final dynamic lastPaymentDate;
  CustomerPaymentData({
    this.accountId,
    this.accountName,
    this.paymentHidden,
    this.hiddenBy,
    this.hiddenByName,
    this.hiddenDate,
    this.pendingAmount,
    this.lastPaymentDate,
  });

  factory CustomerPaymentData.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentData(
      accountId: json['account_id']?.toString(),
      accountName: json['account_name'],
      paymentHidden: json['payment_hidden']?.toString(),
      hiddenBy: json['hidden_by'],
      hiddenByName: json['hidden_by_name'],
      hiddenDate: json['hidden_date'],
      pendingAmount: json['pending_amount'],
      lastPaymentDate: json['last_payment_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'account_name': accountName,
      'payment_hidden': paymentHidden,
      'hidden_by': hiddenBy,
      'hidden_by_name': hiddenByName,
      'hidden_date': hiddenDate,
      'pending_amount': pendingAmount,
      'last_payment_date': lastPaymentDate,
    };
  }
}
