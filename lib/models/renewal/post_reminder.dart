// To parse this JSON data, do
//
//     final postReminderModel = postReminderModelFromJson(jsonString);

import 'dart:convert';

PostReminderModel postReminderModelFromJson(String str) => PostReminderModel.fromJson(json.decode(str));

String postReminderModelToJson(PostReminderModel data) => json.encode(data.toJson());

class PostReminderModel {
    String message;
    bool data;
    bool status;

    PostReminderModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory PostReminderModel.fromJson(Map<String, dynamic> json) => PostReminderModel(
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
