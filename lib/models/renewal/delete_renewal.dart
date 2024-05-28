// To parse this JSON data, do
//
//     final deleteRenewalModel = deleteRenewalModelFromJson(jsonString);

import 'dart:convert';

DeleteRenewalModel deleteRenewalModelFromJson(String str) => DeleteRenewalModel.fromJson(json.decode(str));

String deleteRenewalModelToJson(DeleteRenewalModel data) => json.encode(data.toJson());

class DeleteRenewalModel {
    String message;
    bool data;
    bool status;

    DeleteRenewalModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory DeleteRenewalModel.fromJson(Map<String, dynamic> json) => DeleteRenewalModel(
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
