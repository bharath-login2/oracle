// To parse this JSON data, do
//
//     final hiddenListModel = hiddenListModelFromJson(jsonString);

import 'dart:convert';

HiddenListModel hiddenListModelFromJson(String str) => HiddenListModel.fromJson(json.decode(str));

String hiddenListModelToJson(HiddenListModel data) => json.encode(data.toJson());

class HiddenListModel {
    Data data;
    bool status;
    String message;

    HiddenListModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory HiddenListModel.fromJson(Map<String, dynamic> json) => HiddenListModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
    };
}

class Data {
    List<ListElement> lists;
    int recordCount;

    Data({
        required this.lists,
        required this.recordCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        recordCount: json["record_count"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "record_count": recordCount,
    };
}

class ListElement {
    String id;
    String templateId;
    String templateName;
    String clientName;
    String clientId;
    String startDate;
    String endDate;
    bool isExpired;
    String remainingDays;
    String products;
    String productId;
    String contactNo;
    String cost;
    String remarks;

    ListElement({
        required this.id,
        required this.templateId,
        required this.templateName,
        required this.clientName,
        required this.clientId,
        required this.startDate,
        required this.endDate,
        required this.isExpired,
        required this.remainingDays,
        required this.products,
        required this.productId,
        required this.contactNo,
        required this.cost,
        required this.remarks,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        templateId: json["template_id"],
        templateName: json["template_name"],
        clientName: json["client_name"],
        clientId: json["client_id"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        isExpired: json["is_expired"],
        remainingDays: json["remaining_days"],
        products: json["products"],
        productId: json["product_id"],
        contactNo: json["contact_no"],
        cost: json["cost"],
        remarks: json["remarks"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "template_id": templateId,
        "template_name": templateName,
        "client_name": clientName,
        "client_id": clientId,
        "start_date": startDate,
        "end_date": endDate,
        "is_expired": isExpired,
        "remaining_days": remainingDays,
        "products": products,
        "product_id": productId,
        "contact_no": contactNo,
        "cost": cost,
        "remarks": remarks,
    };
}
