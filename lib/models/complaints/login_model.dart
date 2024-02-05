// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
    bool status;
    String message;
    Data data;

    LoginModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String token;
    String userId;
    String name;
    String role;
    String roleId;
    String isMultiBranch;

    Data({
        required this.token,
        required this.userId,
        required this.name,
        required this.role,
        required this.roleId,
        required this.isMultiBranch,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        userId: json["user_id"],
        name: json["name"],
        role: json["role"],
        roleId: json["role_id"],
        isMultiBranch: json["is_multi_branch"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user_id": userId,
        "name": name,
        "role": role,
        "role_id": roleId,
        "is_multi_branch": isMultiBranch,
    };
}
