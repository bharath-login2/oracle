// To parse this JSON data, do
//
//     final getWhatsappChat = getWhatsappChatFromJson(jsonString);

import 'dart:convert';

GetWhatsappChat getWhatsappChatFromJson(String str) => GetWhatsappChat.fromJson(json.decode(str));

String getWhatsappChatToJson(GetWhatsappChat data) => json.encode(data.toJson());

class GetWhatsappChat {
    String data;
    bool status;
    String message;

    GetWhatsappChat({
        required this.data,
        required this.status,
        required this.message,
    });

    factory GetWhatsappChat.fromJson(Map<String, dynamic> json) => GetWhatsappChat(
        data: json["data"],
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
        "status": status,
        "message": message,
    };
}
