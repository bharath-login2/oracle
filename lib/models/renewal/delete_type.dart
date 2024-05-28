// To parse this JSON data, do
//
//     final deleteTypeModel = deleteTypeModelFromJson(jsonString);

import 'dart:convert';

DeleteTypeModel deleteTypeModelFromJson(String str) => DeleteTypeModel.fromJson(json.decode(str));

String deleteTypeModelToJson(DeleteTypeModel data) => json.encode(data.toJson());

class DeleteTypeModel {
    String message;
    bool data;
    bool status;

    DeleteTypeModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory DeleteTypeModel.fromJson(Map<String, dynamic> json) => DeleteTypeModel(
        message: json["message"],
        data: json["data"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
    };
}
