// To parse this JSON data, do
//
//     final addCustomerModel = addCustomerModelFromJson(jsonString);

import 'dart:convert';

AddCustomerModel addCustomerModelFromJson(String str) => AddCustomerModel.fromJson(json.decode(str));

String addCustomerModelToJson(AddCustomerModel data) => json.encode(data.toJson());

class AddCustomerModel {
    String message;
    bool data;
    bool status;

    AddCustomerModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory AddCustomerModel.fromJson(Map<String, dynamic> json) => AddCustomerModel(
        message: json["message"],
        data:json["data"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
    };
}


