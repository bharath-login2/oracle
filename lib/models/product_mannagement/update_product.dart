// To parse this JSON data, do
//
//     final updateProductCategoryModel = updateProductCategoryModelFromJson(jsonString);

import 'dart:convert';

UpdateProductCategoryModel updateProductCategoryModelFromJson(String str) => UpdateProductCategoryModel.fromJson(json.decode(str));

String updateProductCategoryModelToJson(UpdateProductCategoryModel data) => json.encode(data.toJson());

class UpdateProductCategoryModel {
    String message;
    bool data;
    bool status;

    UpdateProductCategoryModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory UpdateProductCategoryModel.fromJson(Map<String, dynamic> json) => UpdateProductCategoryModel(
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
