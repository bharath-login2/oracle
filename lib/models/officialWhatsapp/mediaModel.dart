class MediaModel {
  List<Data>? data;
  bool? status;
  String? message;

  MediaModel({this.data, this.status, this.message});

  MediaModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['file_name'] = this.fileName;
    data['extension'] = this.extension;
    data['file_type'] = this.fileType;
    data['file_size'] = this.fileSize;
    data['file_id'] = this.fileId;
    return data;
  }
}