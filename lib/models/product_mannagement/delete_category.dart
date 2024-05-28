// To parse this JSON data, do
//
//     final deleteProductCategoryModel = deleteProductCategoryModelFromJson(jsonString);

import 'dart:convert';

DeleteProductCategoryModel deleteProductCategoryModelFromJson(String str) => DeleteProductCategoryModel.fromJson(json.decode(str));

String deleteProductCategoryModelToJson(DeleteProductCategoryModel data) => json.encode(data.toJson());

class DeleteProductCategoryModel {
    String message;
    bool data;
    bool status;

    DeleteProductCategoryModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory DeleteProductCategoryModel.fromJson(Map<String, dynamic> json) => DeleteProductCategoryModel(
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
