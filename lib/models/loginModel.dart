class LoginModel {
  bool? status;
  String? message;
  Data? data;

  LoginModel({this.status, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? token;
  String? userId;
  String? name;
  String? role;
  String? roleId;
  String? isMultiBranch;

  Data(
      {this.token,
        this.userId,
        this.name,
        this.role,
        this.roleId,
        this.isMultiBranch});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userId = json['user_id'];
    name = json['name'];
    role = json['role'];
    roleId = json['role_id'];
    isMultiBranch = json['is_multi_branch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['user_id'] = userId;
    data['name'] = name;
    data['role'] = role;
    data['role_id'] = roleId;
    data['is_multi_branch'] = isMultiBranch;
    return data;
  }
}