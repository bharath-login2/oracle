class StaffDocumentUploadModel {
  bool? status;
  String? message;
  List<DocumentData>? data;

  StaffDocumentUploadModel({this.status, this.message, this.data});

  StaffDocumentUploadModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <DocumentData>[];
      json['data'].forEach((v) {
        data!.add(DocumentData.fromJson(v));
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

class DocumentData {
  String? fileId;
  String? folderId;
  String? fileName;

  DocumentData({this.fileId, this.folderId, this.fileName});

  DocumentData.fromJson(Map<String, dynamic> json) {
    fileId = json['file_id'];
    folderId = json['folder_id'];
    fileName = json['file_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_id'] = fileId;
    data['folder_id'] = folderId;
    data['file_name'] = fileName;
    return data;
  }
}