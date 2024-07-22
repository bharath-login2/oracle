// To parse this JSON data, do
//
//     final campaignsOfficialMessageModel = campaignsOfficialMessageModelFromJson(jsonString);

import 'dart:convert';

CampaignsOfficialMessageModel campaignsOfficialMessageModelFromJson(String str) => CampaignsOfficialMessageModel.fromJson(json.decode(str));

String campaignsOfficialMessageModelToJson(CampaignsOfficialMessageModel data) => json.encode(data.toJson());

class CampaignsOfficialMessageModel {
    String groupId;
    String groupName;
    String createdBy;
    String createdTime;
    String campaignId;
    String profilePhoto;
    bool canSend;
    List<Contat> contats;
    List<Message> messages;

    CampaignsOfficialMessageModel({
        required this.groupId,
        required this.groupName,
        required this.createdBy,
        required this.createdTime, 
        required this.campaignId,
        required this.profilePhoto,
        required this.canSend,
        required this.contats,
        required this.messages,
    });

    factory CampaignsOfficialMessageModel.fromJson(Map<String, dynamic> json) => CampaignsOfficialMessageModel(
        groupId: json["group_id"],
        groupName: json["group_name"],
        createdBy: json["created_by"],
        createdTime:json["created_time"],
        campaignId: json["campaign_id"],
        profilePhoto: json["profile_photo"],
        canSend: json["canSend"],
        contats: List<Contat>.from(json["contats"].map((x) => Contat.fromJson(x))),
        messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "created_by": createdBy,
        "created_time": createdTime,
        "campaign_id": campaignId,
        "profile_photo": profilePhoto,
        "canSend": canSend,
        "contats": List<dynamic>.from(contats.map((x) => x.toJson())),
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    };
}

class Contat {
    String id;
    String groupId;
    DateTime joinedDatetime;
    String contactName;
    String countryCode;
    String phoneNumber;

    Contat({
        required this.id,
        required this.groupId,
        required this.joinedDatetime,
        required this.contactName,
        required this.countryCode,
        required this.phoneNumber,
    });

    factory Contat.fromJson(Map<String, dynamic> json) => Contat(
        id: json["id"],
        groupId: json["group_id"],
        joinedDatetime: DateTime.parse(json["joined_datetime"]),
        contactName: json["contact_name"],
        countryCode: json["country_code"],
        phoneNumber: json["phone_number"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "group_id": groupId,
        "joined_datetime": joinedDatetime.toIso8601String(),
        "contact_name": contactName,
        "country_code": countryCode,
        "phone_number": phoneNumber,
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
    String messageBody;
    String latitude;
    String longitude;
    String footer;
    List<Button> buttons;
    String headerText;
    String headerSubText;

    MessageText({
        required this.format,
        required this.url,
        required this.fileName,
        required this.messageBody,
        required this.latitude,
        required this.longitude,
        required this.footer,
        required this.buttons,
        required this.headerText,
        required this.headerSubText,
    });

    factory MessageText.fromJson(Map<String, dynamic> json) => MessageText(
        format: json["format"],
        url: json["url"],
        fileName: json["fileName"],
        messageBody: json["messageBody"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        footer: json["footer"],
        buttons: List<Button>.from(json["buttons"].map((x) => Button.fromJson(x))),
        headerText: json["headerText"],
        headerSubText: json["headerSubText"],
    );

    Map<String, dynamic> toJson() => {
        "format": format,
        "url": url,
        "fileName": fileName,
        "messageBody": messageBody,
        "latitude": latitude,
        "longitude": longitude,
        "footer": footer,
        "buttons": List<dynamic>.from(buttons.map((x) => x.toJson())),
        "headerText": headerText,
        "headerSubText": headerSubText,
    };
}

class Button {
    String type;
    String text;
    String btnUrl;

    Button({
        required this.type,
        required this.text,
        required this.btnUrl,
    });

    factory Button.fromJson(Map<String, dynamic> json) => Button(
        type: json["type"],
        text: json["text"],
        btnUrl: json["btn_url"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "text": text,
        "btn_url": btnUrl,
    };
}
