// To parse this JSON data, do
//
//     final postProductCategoryModel = postProductCategoryModelFromJson(jsonString);

import 'dart:convert';

PostProductCategoryModel postProductCategoryModelFromJson(String str) => PostProductCategoryModel.fromJson(json.decode(str));

String postProductCategoryModelToJson(PostProductCategoryModel data) => json.encode(data.toJson());

class PostProductCategoryModel {
    String message;
    bool data;
    bool status;

    PostProductCategoryModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory PostProductCategoryModel.fromJson(Map<String, dynamic> json) => PostProductCategoryModel(
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
