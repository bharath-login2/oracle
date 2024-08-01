// To parse this JSON data, do
//
//     final websocketResponseModel = websocketResponseModelFromJson(jsonString);

import 'dart:convert';

WebsocketResponseModel websocketResponseModelFromJson(String str) => WebsocketResponseModel.fromJson(json.decode(str));

String websocketResponseModelToJson(WebsocketResponseModel data) => json.encode(data.toJson());

class WebsocketResponseModel {
    String type;
    String fromUser;
    String callId;
    String message;
    String isNewChat;
    String notificationType;

    WebsocketResponseModel({
        required this.type,
        required this.fromUser,
        required this.callId,
        required this.message,
        required this.isNewChat,
        required this.notificationType,
    });

    factory WebsocketResponseModel.fromJson(Map<String, dynamic> json) => WebsocketResponseModel(
        type: json["type"],
        fromUser: json["from_user"],
        callId: json["call_id"],
        message: json["message"],
        isNewChat: json["is_new_chat"],
        notificationType: json["notification_type"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "from_user": fromUser,
        "call_id": callId,
        "message": message,
        "is_new_chat": isNewChat,
        "notification_type": notificationType,
    };
}
