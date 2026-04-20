class ProductDescriptionModel {
  final bool status;
  final String message;
  final String data;

  ProductDescriptionModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductDescriptionModel.fromJson(Map<String, dynamic> json) {
    return ProductDescriptionModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }

  
}