class MediaModel {
  List<Data>? data;
  bool? status;
  String? message;

  MediaModel({this.data, this.status, this.message});

  MediaModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  String? url;
  String? fileName;
  String? extension;
  String? fileType;
  String? fileSize;
  String? fileId;

  Data(
      {this.url,
        this.fileName,
        this.extension,
        this.fileType,
        this.fileSize,
        this.fileId});

  Data.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    fileName = json['file_name'];
    extension = json['extension'];
    fileType = json['file_type'];
    fileSize = json['file_size'];
    fileId = json['file_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['file_name'] = fileName;
    data['extension'] = extension;
    data['file_type'] = fileType;
    data['file_size'] = fileSize;
    data['file_id'] = fileId;
    return data;
  }
}