class RenameGdriveApiModel {
  bool status;
  String message;
  List<dynamic> data;

  RenameGdriveApiModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RenameGdriveApiModel.fromJson(Map<String, dynamic> json) {
    return RenameGdriveApiModel(
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