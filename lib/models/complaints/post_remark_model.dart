// To parse this JSON data, do
//
//     final postRemarkModel = postRemarkModelFromJson(jsonString);

import 'dart:convert';

PostRemarkModel postRemarkModelFromJson(String str) => PostRemarkModel.fromJson(json.decode(str));

String postRemarkModelToJson(PostRemarkModel data) => json.encode(data.toJson());

class PostRemarkModel {
    String message;
    bool data;
    bool status;

    PostRemarkModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory PostRemarkModel.fromJson(Map<String, dynamic> json) => PostRemarkModel(
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
