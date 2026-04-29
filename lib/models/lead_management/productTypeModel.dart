class ProductTypeResponse {
  final bool status;
  final String message;
  final List<String> data;

  ProductTypeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductTypeResponse.fromJson(Map<String, dynamic> json) {
    return ProductTypeResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
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