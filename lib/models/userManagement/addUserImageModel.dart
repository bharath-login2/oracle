class AddUserImageModel {
  bool? status;
  String? message;
  bool? data;

  AddUserImageModel({this.status, this.message, this.data});

  AddUserImageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}