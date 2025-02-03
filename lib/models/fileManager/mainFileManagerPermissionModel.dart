class MainFileManagerPermissionModel {
  bool? status;
  String? message;
  Data? data;

  MainFileManagerPermissionModel({this.status, this.message, this.data});

  MainFileManagerPermissionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  bool? createFile;
  bool? openFile;
  bool? renameFile;
  bool? deleteFile;
  bool? downloadFile;
  String? maxFileSize;
  String? remainingStorage;
  String? totalStorage;
  String? percentageComplete;

  Data(
      {this.createFile,
        this.openFile,
        this.renameFile,
        this.deleteFile,
        this.downloadFile,
        this.maxFileSize,
        this.remainingStorage,
        this.totalStorage,
        this.percentageComplete});

  Data.fromJson(Map<String, dynamic> json) {
    createFile = json['create_file'];
    openFile = json['open_file'];
    renameFile = json['rename_file'];
    deleteFile = json['delete_file'];
    downloadFile = json['download_file'];
    maxFileSize = json['max_file_size'];
    remainingStorage = json['remainingStorage'];
    totalStorage = json['totalStorage'];
    percentageComplete = json['percentageComplete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['create_file'] = createFile;
    data['open_file'] = openFile;
    data['rename_file'] = renameFile;
    data['delete_file'] = deleteFile;
    data['download_file'] = downloadFile;
    data['max_file_size'] = maxFileSize;
    data['remainingStorage'] = remainingStorage;
    data['totalStorage'] = totalStorage;
    data['percentageComplete'] = percentageComplete;
    return data;
  }
}