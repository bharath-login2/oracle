// To parse this JSON data, do
//
//     final whatsappContacts = whatsappContactsFromJson(jsonString);

import 'dart:convert';

WhatsappContacts whatsappContactsFromJson(String str) => WhatsappContacts.fromJson(json.decode(str));

String whatsappContactsToJson(WhatsappContacts data) => json.encode(data.toJson());

class WhatsappContacts {
    List<ContactList> data;
    bool status;
    String message;

    WhatsappContacts({
        required this.data,
        required this.status,
        required this.message,
    });

    factory WhatsappContacts.fromJson(Map<String, dynamic> json) => WhatsappContacts(
        data: List<ContactList>.from(json["data"].map((x) => ContactList.fromJson(x))),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
    };
}

class ContactList {
    String groupId;
    String groupName;
    String phoneNumber;

    ContactList({
        required this.groupId,
        required this.groupName,
        required this.phoneNumber,
    });

    factory ContactList.fromJson(Map<String, dynamic> json) => ContactList(
        groupId: json["group_id"],
        groupName: json["group_name"],
        phoneNumber: json["phone_number"],
    );

    Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "phone_number": phoneNumber,
    };
}
