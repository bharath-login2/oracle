class CustomerHiddenPaymentReportModel {
  final List<CustomerHiddenPaymentData>? data;
  final bool? status;
  final String? message;

  CustomerHiddenPaymentReportModel({
    this.data,
    this.status,
    this.message,
  });

  factory CustomerHiddenPaymentReportModel.fromJson(Map<String, dynamic> json) {
    return CustomerHiddenPaymentReportModel(
      data: json['data'] != null
          ? List<CustomerHiddenPaymentData>.from(
              json['data'].map((x) => CustomerHiddenPaymentData.fromJson(x)))
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

  bool get isSuccess => status == true;
  bool get hasError => status == false;
  @override
  String toString() {
    return 'CustomerHiddenPaymentReportModel(data: ${data?.length}, status: $status, message: $message)';
  }
}

class CustomerHiddenPaymentData {
  final String? accountId;
  final String? accountName;
  final String? paymentHidden;
  final String? hiddenBy;
  final String? hiddenByName;
  final String? hiddenDate;
  final dynamic pendingAmount;
  CustomerHiddenPaymentData({
    this.accountId,
    this.accountName,
    this.paymentHidden,
    this.hiddenBy,
    this.hiddenByName,
    this.hiddenDate,
    this.pendingAmount,
  });

  factory CustomerHiddenPaymentData.fromJson(Map<String, dynamic> json) {
    return CustomerHiddenPaymentData(
      accountId: json['account_id']?.toString(),
      accountName: json['account_name'],
      paymentHidden: json['payment_hidden']?.toString(),
      hiddenBy: json['hidden_by']?.toString(),
      hiddenByName: json['hidden_by_name'],
      hiddenDate: json['hidden_date'],
      pendingAmount: json['pending_amount'],
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
    };
  }
}
