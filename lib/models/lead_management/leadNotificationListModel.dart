// To parse this JSON data, do
//
//     final leadNotificationListModel = leadNotificationListModelFromJson(jsonString);

import 'dart:convert';

LeadNotificationListModel leadNotificationListModelFromJson(String str) =>
    LeadNotificationListModel.fromJson(json.decode(str));

class LeadNotificationListModel {
  bool status;
  bool message;
  List<Datum> data;

  LeadNotificationListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadNotificationListModel.fromJson(Map<String, dynamic> json) =>
      LeadNotificationListModel(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  String notificationId;
  String title;
  String content;
  String id;
  dynamic dateTime;
  bool isRead;
  String type;

  Datum({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.id,
    required this.dateTime,
    required this.isRead,
    required this.type,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        notificationId: json["notification_id"],
        title: json["title"],
        content: json["content"],
        id: json["id"],
        dateTime: json["date_time"],
        isRead: json["is_read"],
        type: json["type"],
      );
}
