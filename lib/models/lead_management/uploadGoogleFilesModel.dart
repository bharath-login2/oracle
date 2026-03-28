class UploadGoogleFilesResponse {
  final bool status;
  final String message;

  UploadGoogleFilesResponse({
    required this.status,
    required this.message,
  });

  factory UploadGoogleFilesResponse.fromJson(Map<String, dynamic> json) {
    return UploadGoogleFilesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'UploadGoogleFilesResponse(status: $status, message: $message)';
  }
}
