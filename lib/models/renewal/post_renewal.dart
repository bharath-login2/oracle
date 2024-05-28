// To parse this JSON data, do
//
//     final postRenewalModel = postRenewalModelFromJson(jsonString);

import 'dart:convert';

PostRenewalModel postRenewalModelFromJson(String str) => PostRenewalModel.fromJson(json.decode(str));

String postRenewalModelToJson(PostRenewalModel data) => json.encode(data.toJson());

class PostRenewalModel {
    String message;
    bool data;
    bool status;

    PostRenewalModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory PostRenewalModel.fromJson(Map<String, dynamic> json) => PostRenewalModel(
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


