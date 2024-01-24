// To parse this JSON data, do
//
//     final chatListModel = chatListModelFromJson(jsonString);

import 'dart:convert';

ChatListModel chatListModelFromJson(String str) => ChatListModel.fromJson(json.decode(str));

String chatListModelToJson(ChatListModel data) => json.encode(data.toJson());

class ChatListModel {
  List<Datum> data;
  bool message;
  bool status;

  ChatListModel({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
    "status": status,
  };
}

class Datum {
  String groupId;
  String profilePic;
  String groupName;
  String phoneNumber;
  String lastMsgTime;
  bool canSendMessage;
  String msgStatus;
  String lastMessage;
  bool fromMe;

  Datum({
    required this.groupId,
    required this.profilePic,
    required this.groupName,
    required this.phoneNumber,
    required this.lastMsgTime,
    required this.canSendMessage,
    required this.msgStatus,
    required this.lastMessage,
    required this.fromMe,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    groupId: json["group_id"],
    profilePic: json["profile_pic"],
    groupName: json["group_name"],
    phoneNumber: json["phone_number"],
    lastMsgTime: json["last_msg_time"],
    canSendMessage: json["canSendMessage"],
    msgStatus: json["msgStatus"],
    lastMessage: json["lastMessage"],
    fromMe: json["fromMe"],
  );

  Map<String, dynamic> toJson() => {
    "group_id": groupId,
    "profile_pic": profilePic,
    "group_name": groupName,
    "phone_number": phoneNumber,
    "last_msg_time": lastMsgTime,
    "canSendMessage": canSendMessage,
    "msgStatus": msgStatus,
    "lastMessage": lastMessage,
    "fromMe": fromMe,
  };
}
