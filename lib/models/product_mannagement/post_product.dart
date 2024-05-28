// To parse this JSON data, do
//
//     final postProductModel = postProductModelFromJson(jsonString);

import 'dart:convert';

PostProductModel postProductModelFromJson(String str) => PostProductModel.fromJson(json.decode(str));

String postProductModelToJson(PostProductModel data) => json.encode(data.toJson());

class PostProductModel {
    String message;
    bool data;
    bool status;

    PostProductModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory PostProductModel.fromJson(Map<String, dynamic> json) => PostProductModel(
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
