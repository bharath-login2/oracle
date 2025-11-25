class DocumentListModel {
  final List<DocumentData> data;
  final bool status;
  final String message;

  DocumentListModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory DocumentListModel.fromJson(Map<String, dynamic> json) {
    return DocumentListModel(
      data: (json['data'] as List<dynamic>)
          .map((item) => DocumentData.fromJson(item))
          .toList(),
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'status': status,
      'message': message,
    };
  }
}

class DocumentData {
  final String id;
  final String documentName;

  DocumentData({
    required this.id,
    required this.documentName,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) {
    return DocumentData(
      id: json['id'] ?? '',
      documentName: json['document_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_name': documentName,
    };
  }
}
