// To parse this JSON data, do
//
//     final editRenewalModel = editRenewalModelFromJson(jsonString);

import 'dart:convert';

EditRenewalModel editRenewalModelFromJson(String str) => EditRenewalModel.fromJson(json.decode(str));

String editRenewalModelToJson(EditRenewalModel data) => json.encode(data.toJson());

class EditRenewalModel {
    String message;
    bool data;
    bool status;

    EditRenewalModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory EditRenewalModel.fromJson(Map<String, dynamic> json) => EditRenewalModel(
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
