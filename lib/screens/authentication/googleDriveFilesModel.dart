class GoogleDriveFilesResponse {
  final bool status;
  final String message;
  final List<GoogleDriveFile> data;

  GoogleDriveFilesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GoogleDriveFilesResponse.fromJson(Map<String, dynamic> json) {
    return GoogleDriveFilesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => GoogleDriveFile.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class GoogleDriveFile {
  final String fileName;
  final String uploadedAt;
  final String webViewLink;
  final String webContentLink;
  final String? thumbnailLink;

  GoogleDriveFile({
    required this.fileName,
    required this.uploadedAt,
    required this.webViewLink,
    required this.webContentLink,
    this.thumbnailLink,
  });

  factory GoogleDriveFile.fromJson(Map<String, dynamic> json) {
    return GoogleDriveFile(
      fileName: json['file_name'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      webViewLink: json['webViewLink'] ?? '',
      webContentLink: json['webContentLink'] ?? '',
      thumbnailLink: json['thumbnailLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'uploaded_at': uploadedAt,
      'webViewLink': webViewLink,
      'webContentLink': webContentLink,
      'thumbnailLink': thumbnailLink,
    };
  }
}
