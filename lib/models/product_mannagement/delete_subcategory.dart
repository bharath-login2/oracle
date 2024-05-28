// To parse this JSON data, do
//
//     final deleteProductSubCategoryModel = deleteProductSubCategoryModelFromJson(jsonString);

import 'dart:convert';

DeleteProductSubCategoryModel deleteProductSubCategoryModelFromJson(String str) => DeleteProductSubCategoryModel.fromJson(json.decode(str));

String deleteProductSubCategoryModelToJson(DeleteProductSubCategoryModel data) => json.encode(data.toJson());

class DeleteProductSubCategoryModel {
    String message;
    bool data;
    bool status;

    DeleteProductSubCategoryModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory DeleteProductSubCategoryModel.fromJson(Map<String, dynamic> json) => DeleteProductSubCategoryModel(
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
