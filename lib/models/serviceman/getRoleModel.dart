import 'package:meta/meta.dart';
import 'dart:convert';

class GetRoleModel {
  String status;
  Data data;

  GetRoleModel({required this.status, required this.data});

  factory GetRoleModel.fromRawJson(String str) =>
      GetRoleModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetRoleModel.fromJson(Map<String, dynamic> json) =>
      GetRoleModel(status: json["status"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class Data {
  String role;

  Data({required this.role});

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(role: json["role"]);

  Map<String, dynamic> toJson() => {"role": role};
}
