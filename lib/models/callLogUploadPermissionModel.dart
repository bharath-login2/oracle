class CallLogUploadPermissionModel {
  String? message;
  Data? data;
  bool? status;

  CallLogUploadPermissionModel({this.message, this.data, this.status});

  CallLogUploadPermissionModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class Data {
  bool? incoming;
  bool? outgoing;

  Data({this.incoming, this.outgoing});

  Data.fromJson(Map<String, dynamic> json) {
    incoming = json['incoming'];
    outgoing = json['outgoing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['incoming'] = incoming;
    data['outgoing'] = outgoing;
    return data;
  }
}