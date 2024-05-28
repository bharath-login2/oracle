// To parse this JSON data, do
//
//     final hideModel = hideModelFromJson(jsonString);

import 'dart:convert';

HideModel hideModelFromJson(String str) => HideModel.fromJson(json.decode(str));

String hideModelToJson(HideModel data) => json.encode(data.toJson());

class HideModel {
    String message;
    bool data;
    bool status;

    HideModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory HideModel.fromJson(Map<String, dynamic> json) => HideModel(
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
