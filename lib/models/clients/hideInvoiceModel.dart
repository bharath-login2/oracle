class HideInvoiceModel {
  final dynamic data;
  final bool? status;
  final String? message;

  HideInvoiceModel({
    this.data,
    this.status,
    this.message,
  });

  factory HideInvoiceModel.fromJson(Map<String, dynamic> json) {
    return HideInvoiceModel(
      data: json['data'], 
      status: json['status'] as bool?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'status': status,
      'message': message,
    };
  }
}
