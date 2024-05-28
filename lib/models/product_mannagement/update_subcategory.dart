// To parse this JSON data, do
//
//     final updateProductSubCategoryModel = updateProductSubCategoryModelFromJson(jsonString);

import 'dart:convert';

UpdateProductSubCategoryModel updateProductSubCategoryModelFromJson(String str) => UpdateProductSubCategoryModel.fromJson(json.decode(str));

String updateProductSubCategoryModelToJson(UpdateProductSubCategoryModel data) => json.encode(data.toJson());

class UpdateProductSubCategoryModel {
    String message;
    bool data;
    bool status;

    UpdateProductSubCategoryModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory UpdateProductSubCategoryModel.fromJson(Map<String, dynamic> json) => UpdateProductSubCategoryModel(
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
