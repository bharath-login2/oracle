
class FileManagerModel {
  bool? status;
  String? message;
  List<Data>? data;

  FileManagerModel({this.status, this.message, this.data});

  FileManagerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  String? id;
  String? name;
  String? path;
  String? extension;
  String? isFolder;
  bool? isSelected;
  String? fileSize;
  String? createdBy;
  String? createdAt;

  Data(
      {this.id,
        this.name,
        this.path,
        this.extension,
        this.isFolder,
        this.isSelected,
        this.fileSize,
        this.createdBy,
        this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    path = json['path'];
    extension = json['extension'];
    isFolder = json['is_folder'];
    isSelected = json['is_selected'];
    fileSize = json['file_size'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['path'] = path;
    data['extension'] = extension;
    data['is_folder'] = isFolder;
    data['is_selected'] = isSelected;
    data['file_size'] = fileSize;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    return data;
  }
}