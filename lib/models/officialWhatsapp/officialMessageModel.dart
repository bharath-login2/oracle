// To parse this JSON data, do
//
//     final officialMessageModel = officialMessageModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

OfficialMessageModel officialMessageModelFromJson(String str) =>
    OfficialMessageModel.fromJson(json.decode(str));

String officialMessageModelToJson(OfficialMessageModel data) =>
    json.encode(data.toJson());

class OfficialMessageModel {
  String groupId;
  String groupName;
  String phoneNumber;
  DateTime sentTime;
  String toNumber;
  String createdBy;
  DateTime createdTime;
  String campaignId;
  String profilePhoto;
  int timeDiff;
  bool canSend;
  List<Message> messages;

  OfficialMessageModel({
    required this.groupId,
    required this.groupName,
    required this.phoneNumber,
    required this.sentTime,
    required this.toNumber,
    required this.createdBy,
    required this.createdTime,
    required this.campaignId,
    required this.profilePhoto,
    required this.timeDiff,
    required this.canSend,
    required this.messages,
  });

  factory OfficialMessageModel.fromJson(Map<String, dynamic> json) =>
      OfficialMessageModel(
        groupId: json["group_id"],
        groupName: json["group_name"],
        phoneNumber: json["phone_number"],
        sentTime: json["sent_time"] != ""
            ? DateTime.parse(json["sent_time"])
            : DateTime.now(),
        toNumber: json["to_number"],
        createdBy: json["created_by"],
        createdTime: DateTime.parse(json["created_time"]),
        campaignId: json["campaign_id"],
        profilePhoto: json["profile_photo"],
        timeDiff: json["timeDiff"],
        canSend: json["canSend"],
        messages: List<Message>.from(
            json["messages"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "phone_number": phoneNumber,
        "sent_time": sentTime.toIso8601String(),
        "to_number": toNumber,
        "created_by": createdBy,
        "created_time": createdTime.toIso8601String(),
        "campaign_id": campaignId,
        "profile_photo": profilePhoto,
        "timeDiff": timeDiff,
        "canSend": canSend,
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
      };
}

class Message {
  bool fromMe;
  String sentTime;
  String status;
  MessageText messageText;

  Message({
    required this.fromMe,
    required this.sentTime,
    required this.status,
    required this.messageText,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        fromMe: json["fromMe"],
        sentTime: json["sentTime"],
        status: json["status"],
        messageText: MessageText.fromJson(json["messageText"]),
      );

  Map<String, dynamic> toJson() => {
        "fromMe": fromMe,
        "sentTime": sentTime,
        "status": status,
        "messageText": messageText.toJson(),
      };
}

class MessageText {
  String format;
  String url;
  String fileName;
  String headerText;
  String headerSubText;
  String messageBody;
  String footer;
  List<Button> buttons;

  MessageText({
    required this.format,
    required this.url,
    required this.fileName,
    required this.headerText,
    required this.headerSubText,
    required this.messageBody,
    required this.footer,
    required this.buttons,
  });

  factory MessageText.fromJson(Map<String, dynamic> json) => MessageText(
        format: json["format"],
        url: json["url"],
        fileName: json["fileName"],
        headerText: json["headerText"],
        headerSubText: json["headerSubText"],
        messageBody: json["messageBody"],
        footer: json["footer"],
        buttons:
            List<Button>.from(json["buttons"].map((x) => Button.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "format": format,
        "url": url,
        "fileName": fileName,
        "headerText": headerText,
        "headerSubText": headerSubText,
        "messageBody": messageBody,
        "footer": footer,
        "buttons": List<dynamic>.from(buttons.map((x) => x.toJson())),
      };
}

class Button {
  String type;
  String text;
  String btnUrl;
  List<ButtonData> data;

  Button({
    required this.type,
    required this.text,
    required this.btnUrl,
    required this.data,
  });

  factory Button.fromJson(Map<String, dynamic> json) => Button(
        type: json["type"],
        text: json["text"],
        btnUrl: json["btn_url"],
        data: List<ButtonData>.from(
            json["data"].map((x) => ButtonData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "text": text,
        "btn_url": btnUrl,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ButtonData {
  String sectionName;
  List<Option> options;

  ButtonData({
    required this.sectionName,
    required this.options,
  });

  factory ButtonData.fromJson(Map<String, dynamic> json) => ButtonData(
        sectionName: json["section_name"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "section_name": sectionName,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
      };
}

class Option {
  String productName;
  String productDescription;
  String productMrp;
  String productSellingPrice;
  String productUrl;

  Option({
    required this.productName,
    required this.productDescription,
    required this.productMrp,
    required this.productSellingPrice,
    required this.productUrl,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        productName: json["product_name"],
        productDescription: json["product_description"],
        productMrp: json["product_mrp"],
        productSellingPrice: json["product_selling_price"],
        productUrl: json["product_url"],
      );

  Map<String, dynamic> toJson() => {
        "product_name": productName,
        "product_description": productDescription,
        "product_mrp": productMrp,
        "product_selling_price": productSellingPrice,
        "product_url": productUrl,
      };
}
