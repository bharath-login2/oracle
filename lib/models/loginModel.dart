class LoginModel {
  bool? status;
  String? message;
  Data? data;

  LoginModel({this.status, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  String? token;
  String? userId;
  String? name;
  String? accountName;
  String? accountId;
  String? role;
  String? roleId;
  String? isMultiBranch;

  Data(
      {this.token,
      this.userId,
      this.name,
      this.accountName,
      this.accountId,
      this.role,
      this.roleId,
      this.isMultiBranch});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userId = json['user_id'];
    name = json['name'];
    accountName = json['account_name'];
    accountId = json['account_id'];
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
