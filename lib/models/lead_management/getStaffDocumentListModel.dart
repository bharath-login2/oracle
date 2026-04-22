class GetStaffDocumentListModel {
  bool? status;
  String? message;
  List<StaffDocument>? data;

  GetStaffDocumentListModel({this.status, this.message, this.data});

  GetStaffDocumentListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <StaffDocument>[];
      json['data'].forEach((v) {
        data!.add(StaffDocument.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StaffDocument {
  String? fileId;
  String? fileName;
  String? accountId;
  String? uploadedAt;
  String? webViewLink;
  String? webContentLink;
  String? thumbnailLink;

  StaffDocument({
    this.fileId,
    this.fileName,
    this.accountId,
    this.uploadedAt,
    this.webViewLink,
    this.webContentLink,
    this.thumbnailLink,
  });

  StaffDocument.fromJson(Map<String, dynamic> json) {
    fileId = json['file_id'];
    fileName = json['file_name'];
    accountId = json['account_id'];
    uploadedAt = json['uploaded_at'];
    webViewLink = json['webViewLink'];
    webContentLink = json['webContentLink'];
    thumbnailLink = json['thumbnailLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_id'] = fileId;
    data['file_name'] = fileName;
    data['account_id'] = accountId;
    data['uploaded_at'] = uploadedAt;
    data['webViewLink'] = webViewLink;
    data['webContentLink'] = webContentLink;
    data['thumbnailLink'] = thumbnailLink;
    return data;
  }
}