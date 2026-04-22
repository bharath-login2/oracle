class DeleteRentalReturnModel {
  bool status;
  String message;
  List<dynamic> data;

  DeleteRentalReturnModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeleteRentalReturnModel.fromJson(Map<String, dynamic> json) {
    return DeleteRentalReturnModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? [],
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