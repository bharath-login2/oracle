// To parse this JSON data, do
//
//     final isCustomerExistModel = isCustomerExistModelFromJson(jsonString);

import 'dart:convert';

IsCustomerExistModel isCustomerExistModelFromJson(String str) => IsCustomerExistModel.fromJson(json.decode(str));

String isCustomerExistModelToJson(IsCustomerExistModel data) => json.encode(data.toJson());

class IsCustomerExistModel {
    String message;
    bool data;
    bool status;

    IsCustomerExistModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory IsCustomerExistModel.fromJson(Map<String, dynamic> json) => IsCustomerExistModel(
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
