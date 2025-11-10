// To parse this JSON data, do
//
//     final officialMessageModel = officialMessageModelFromJson(jsonString);

import 'dart:convert';

OfficialMessageModel officialMessageModelFromJson(String str) =>
    OfficialMessageModel.fromJson(json.decode(str));

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
  List<ChatMessage> messages;

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
        groupId: json["group_id"] ?? "",
        groupName: json["group_name"] ?? "",
        phoneNumber: json["phone_number"] ?? "",
        sentTime: DateTime.parse(json["sent_time"]),
        toNumber: json["to_number"] ?? "",
        createdBy: json["created_by"] ?? "",
        createdTime: DateTime.parse(json["created_time"]),
        campaignId: json["campaign_id"] ?? "",
        profilePhoto: json["profile_photo"] ?? "",
        timeDiff: json["timeDiff"] ?? 0,
        canSend: json["canSend"] ?? "",
        messages: json["messages"] == null
            ? []
            : List<ChatMessage>.from(
                json["messages"].map((x) => ChatMessage.fromJson(x))),
      );
}

class ChatMessage {
  String messageId;
  bool fromMe;
  String sentTime;
  String status;
  MessageText messageText;

  ChatMessage({
    required this.messageId,
    required this.fromMe,
    required this.sentTime,
    required this.status,
    required this.messageText,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        messageId: json["message_id"] ?? "",
        fromMe: json["fromMe"] ?? "",
        sentTime: json["sentTime"] ?? "",
        status: json["status"] ?? "",
        messageText: MessageText.fromJson(json["messageText"]),
      );
}

class MessageText {
  String format;
  String url;
  String fileName;
  String headerText;
  String headerSubText;
  String messageBody;
  String latitude;
  String longitude;
  String footer;
  String firstName;
  String companyName;
  String contactNo;
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
    required this.latitude,
    required this.longitude,
    required this.firstName,
    required this.companyName,
    required this.contactNo,
  });

  factory MessageText.fromJson(Map<String, dynamic> json) => MessageText(
        format: json["format"] ?? "",
        url: json["url"] ?? "",
        fileName: json["fileName"] ?? "",
        headerText: json["headerText"] ?? "",
        headerSubText: json["headerSubText"] ?? "",
        messageBody: json["messageBody"] ?? "",
        footer: json["footer"] ?? "",
        latitude: json["latitude"] ?? "",
        longitude: json["longitude"] ?? "",
        firstName: json["first_name"] ?? "",
        companyName: json["company_name"] ?? "",
        contactNo: json["contact_no"] ?? "",
        buttons: json["buttons"] == null
            ? []
            : List<Button>.from(json["buttons"].map((x) => Button.fromJson(x))),
      );
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
        type: json["type"] ?? "",
        text: json["text"] ?? "",
        btnUrl: json["btn_url"] ?? "",
        data: json["data"] == null
            ? []
            : List<ButtonData>.from(
                json["data"].map((x) => ButtonData.fromJson(x))),
      );
}

class ButtonData {
  String sectionName;
  List<Option> options;

  ButtonData({
    required this.sectionName,
    required this.options,
  });

  factory ButtonData.fromJson(Map<String, dynamic> json) => ButtonData(
        sectionName: json["section_name"] ?? "",
        options: json["options"] == null
            ? []
            : List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
      );
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
        productName: json["product_name"] ?? "",
        productDescription: json["product_description"] ?? "",
        productMrp: json["product_mrp"] ?? "",
        productSellingPrice: json["product_selling_price"] ?? "",
        productUrl: json["product_url"] ?? "",
      );
}
