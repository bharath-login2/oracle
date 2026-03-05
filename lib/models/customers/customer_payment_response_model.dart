class CustomerPaymentResponseModel {
  final bool? data;
  final bool? status;
  final String? message;

  CustomerPaymentResponseModel({
    this.data,
    this.status,
    this.message,
  });

  factory CustomerPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentResponseModel(
      data: json['data'],
      status: json['status'],
      message: json['message'],
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
