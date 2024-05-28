// To parse this JSON data, do
//
//     final rivertModel = rivertModelFromJson(jsonString);

import 'dart:convert';

RivertModel rivertModelFromJson(String str) => RivertModel.fromJson(json.decode(str));

String rivertModelToJson(RivertModel data) => json.encode(data.toJson());

class RivertModel {
    String message;
    bool data;
    bool status;

    RivertModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory RivertModel.fromJson(Map<String, dynamic> json) => RivertModel(
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
