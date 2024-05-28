// To parse this JSON data, do
//
//     final postProductSubCategoryModel = postProductSubCategoryModelFromJson(jsonString);

import 'dart:convert';

PostProductSubCategoryModel postProductSubCategoryModelFromJson(String str) => PostProductSubCategoryModel.fromJson(json.decode(str));

String postProductSubCategoryModelToJson(PostProductSubCategoryModel data) => json.encode(data.toJson());

class PostProductSubCategoryModel {
    String message;
    bool data;
    bool status;

    PostProductSubCategoryModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory PostProductSubCategoryModel.fromJson(Map<String, dynamic> json) => PostProductSubCategoryModel(
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
