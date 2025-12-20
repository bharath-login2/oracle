// Add to your models section
class DeleteQuotationRequestModel {
  final bool status;
  final String message;
  final dynamic data;

  DeleteQuotationRequestModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory DeleteQuotationRequestModel.fromJson(Map<String, dynamic> json) {
    return DeleteQuotationRequestModel(
      status: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}