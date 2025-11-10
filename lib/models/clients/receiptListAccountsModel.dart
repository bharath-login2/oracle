class ReceiptListAccountsModel {
  final List<ReceiptAccountData>? data;
  final bool? status;
  final String? message;

  ReceiptListAccountsModel({
    this.data,
    this.status,
    this.message,
  });

  factory ReceiptListAccountsModel.fromJson(Map<String, dynamic> json) {
    return ReceiptListAccountsModel(
      data: json['data'] != null
          ? List<ReceiptAccountData>.from(
              json['data'].map((x) => ReceiptAccountData.fromJson(x)))
          : [],
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.map((x) => x.toJson()).toList(),
        'status': status,
        'message': message,
      };
}

class ReceiptAccountData {
  final String? accountName;
  final String? totalReceipt;

  ReceiptAccountData({
    this.accountName,
    this.totalReceipt,
  });

  factory ReceiptAccountData.fromJson(Map<String, dynamic> json) {
    return ReceiptAccountData(
      accountName: json['account_name'],
      totalReceipt: json['total_receipt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'account_name': accountName,
        'total_receipt': totalReceipt,
      };
}
