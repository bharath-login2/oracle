// To parse this JSON data, do
//
//     final addContactModel = addContactModelFromJson(jsonString);

import 'dart:convert';

AddContactModel addContactModelFromJson(String str) => AddContactModel.fromJson(json.decode(str));

String addContactModelToJson(AddContactModel data) => json.encode(data.toJson());

class AddContactModel {
  String message;
  bool status;
  bool data;

  AddContactModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory AddContactModel.fromJson(Map<String, dynamic> json) => AddContactModel(
    message: json["message"],
    status: json["status"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "data": data,
  };
}
