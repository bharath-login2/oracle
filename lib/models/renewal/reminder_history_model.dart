// To parse this JSON data, do
//
//     final reminderHistoryModel = reminderHistoryModelFromJson(jsonString);

import 'dart:convert';

ReminderHistoryModel reminderHistoryModelFromJson(String str) => ReminderHistoryModel.fromJson(json.decode(str));

String reminderHistoryModelToJson(ReminderHistoryModel data) => json.encode(data.toJson());

class ReminderHistoryModel {
    List<Datum> data;
    bool status;
    String message;

    ReminderHistoryModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ReminderHistoryModel.fromJson(Map<String, dynamic> json) => ReminderHistoryModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
    };
}

class Datum {
    String createdAt;
    String profileImage;
    String staffName;
    String content;
    bool isRead;

    Datum({
        required this.createdAt,
        required this.profileImage,
        required this.staffName,
        required this.content,
        required this.isRead,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        createdAt: json["created_at"],
        profileImage: json["profile_image"],
        staffName: json["staff_name"],
        content: json["content"],
        isRead: json["is_read"],
    );

    Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "profile_image": profileImage,
        "staff_name": staffName,
        "content": content,
        "is_read": isRead,
    };
}
