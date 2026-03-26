// To parse this JSON data, do
//
//     final chatListModel = chatListModelFromJson(jsonString);

import 'dart:convert';

ChatListModel chatListModelFromJson(String str) =>
    ChatListModel.fromJson(json.decode(str));

String chatListModelToJson(ChatListModel data) => json.encode(data.toJson());

class ChatListModel {
  List<ChatData> data;
  dynamic message;
  bool status;

  ChatListModel({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
        data: json["data"] != null
            ? List<ChatData>.from(json["data"].map((x) => ChatData.fromJson(x)))
            : [],
        message: json["message"],
        status: json["status"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "status": status,
      };
}

class ChatData {
  String groupId;
  String profilePic;
  String groupName;
  String phoneNumber;
  String lastMsgTime;
  bool canSendMessage;
  String msgStatus;
  String lastMessage;
  bool fromMe;
  int unreadMessageCount;
  String chatType;
  ChatData({
    required this.groupId,
    required this.profilePic,
    required this.groupName,
    required this.phoneNumber,
    required this.lastMsgTime,
    required this.canSendMessage,
    required this.msgStatus,
    required this.lastMessage,
    required this.fromMe,
    required this.unreadMessageCount,
    required this.chatType,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) => ChatData(
        groupId: json["group_id"]?.toString() ?? "",
        profilePic: json["profile_pic"]?.toString() ?? "",
        groupName: json["group_name"]?.toString() ?? "",
        phoneNumber: json["phone_number"]?.toString() ?? "",
        lastMsgTime: json["last_msg_time"]?.toString() ?? "",
        canSendMessage: json["canSendMessage"] ?? false,
        msgStatus: json["msgStatus"]?.toString() ?? "",
        lastMessage: json["lastMessage"]?.toString() ?? "",
        fromMe: json["fromMe"] ?? false,
        unreadMessageCount: json["unreadMessageCount"] ?? 0,
        chatType: json["chat_type"]?.toString() ?? "",
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
        "chat_type": chatType,
        "unreadMessageCount": unreadMessageCount,
      };
}
