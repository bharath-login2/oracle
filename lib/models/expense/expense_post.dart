// To parse this JSON data, do
//
//     final expensePostModel = expensePostModelFromJson(jsonString);

import 'dart:convert';

CommonResponse expensePostModelFromJson(String str) => CommonResponse.fromJson(json.decode(str));

String expensePostModelToJson(CommonResponse data) => json.encode(data.toJson());

class CommonResponse {
    bool status;
    String message;
    bool data;

    CommonResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory CommonResponse.fromJson(Map<String, dynamic> json) => CommonResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
    };
}
