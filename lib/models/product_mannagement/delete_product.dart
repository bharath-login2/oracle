// To parse this JSON data, do
//
//     final deleteProductModel = deleteProductModelFromJson(jsonString);

import 'dart:convert';

DeleteProductModel deleteProductModelFromJson(String str) => DeleteProductModel.fromJson(json.decode(str));

String deleteProductModelToJson(DeleteProductModel data) => json.encode(data.toJson());

class DeleteProductModel {
    String message;
    bool data;
    bool status;

    DeleteProductModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory DeleteProductModel.fromJson(Map<String, dynamic> json) => DeleteProductModel(
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
