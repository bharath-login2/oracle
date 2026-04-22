class DeleteGoogleDriveFileModel {
  bool status;
  String message;
  List<dynamic> data;

  DeleteGoogleDriveFileModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeleteGoogleDriveFileModel.fromJson(Map<String, dynamic> json) {
    return DeleteGoogleDriveFileModel(
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