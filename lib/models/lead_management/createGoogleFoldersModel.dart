class CreateGoogleFoldersResponse {
  final bool status;
  final String message;
  final FolderData? data;

  CreateGoogleFoldersResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateGoogleFoldersResponse.fromJson(Map<String, dynamic> json) {
    return CreateGoogleFoldersResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? FolderData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'CreateGoogleFoldersResponse(status: $status, message: $message, data: $data)';
  }
}

class FolderData {
  final String folderId;

  FolderData({
    required this.folderId,
  });

  factory FolderData.fromJson(Map<String, dynamic> json) {
    return FolderData(
      folderId: json['folder_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder_id': folderId,
    };
  }

  @override
  String toString() {
    return 'FolderData(folderId: $folderId)';
  }
}
