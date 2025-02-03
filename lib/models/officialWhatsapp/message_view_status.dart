// To parse this JSON data, do
//
//     final messageViewStatusModel = messageViewStatusModelFromJson(jsonString);

import 'dart:convert';

MessageViewStatusModel messageViewStatusModelFromJson(String str) =>
    MessageViewStatusModel.fromJson(json.decode(str));

class MessageViewStatusModel {
  String message;
  Data data;
  bool status;

  MessageViewStatusModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory MessageViewStatusModel.fromJson(Map<String, dynamic> json) =>
      MessageViewStatusModel(
        message: json["message"],
        data: Data.fromJson(json["data"]),
        status: json["status"],
      );
}

class Data {
  List<TotalCount> totalCounts;
  List<ContactList> contacts;

  Data({
    required this.totalCounts,
    required this.contacts,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalCounts: List<TotalCount>.from(
            json["total_counts"].map((x) => TotalCount.fromJson(x))),
        contacts: List<ContactList>.from(
            json["contacts"].map((x) => ContactList.fromJson(x))),
      );
}

class ContactList {
  String clientName;
  String phone;
  String status;
  String msgStatus;

  ContactList({
    required this.clientName,
    required this.phone,
    required this.status,
    required this.msgStatus,
  });

  factory ContactList.fromJson(Map<String, dynamic> json) => ContactList(
        clientName: json["client_name"],
        phone: json["phone"],
        status: json["status"],
        msgStatus: json["msg_status"],
      );

  Map<String, dynamic> toJson() => {
        "client_name": clientName,
        "phone": phone,
        "status": status,
        "msg_status": msgStatus,
      };
}

class TotalCount {
  String status;
  String dataCount;

  TotalCount({
    required this.status,
    required this.dataCount,
  });

  factory TotalCount.fromJson(Map<String, dynamic> json) => TotalCount(
        status: json["status"],
        dataCount: json["dataCount"],
      );
}
