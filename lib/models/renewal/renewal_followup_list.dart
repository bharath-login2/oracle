// To parse this JSON data, do
//
//     final renewalFollowupListModel = renewalFollowupListModelFromJson(jsonString);

import 'dart:convert';

RenewalFollowupListModel renewalFollowupListModelFromJson(String str) => RenewalFollowupListModel.fromJson(json.decode(str));

String renewalFollowupListModelToJson(RenewalFollowupListModel data) => json.encode(data.toJson());

class RenewalFollowupListModel {
    Data data;
    bool status;
    String message;

    RenewalFollowupListModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory RenewalFollowupListModel.fromJson(Map<String, dynamic> json) => RenewalFollowupListModel(
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

    Data({
        required this.lists,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
    };
}

class ListElement {
    String id;
    String clientName;
    String clientId;
    String startDate;
    String endDate;
    String status;
    String products;
    String contactNo;
    String cost;
    String staffName;
    String remarks;
    String renewalType;
    String renewalStatus;
    String followUpDate;

    ListElement({
        required this.id,
        required this.clientName,
        required this.clientId,
        required this.startDate,
        required this.endDate,
        required this.status,
        required this.products,
        required this.contactNo,
        required this.cost,
        required this.staffName,
        required this.remarks,
        required this.renewalType,
        required this.renewalStatus,
        required this.followUpDate,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        clientName: json["client_name"],
        clientId: json["client_id"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        status: json["status"],
        products: json["products"],
        contactNo: json["contact_no"],
        cost: json["cost"],
        staffName: json["staff_name"],
        remarks: json["remarks"],
        renewalType: json["renewal_type"],
        renewalStatus: json["renewal_status"],
        followUpDate: json["follow_up_date"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "client_name": clientName,
        "client_id": clientId,
        "start_date": startDate,
        "end_date": endDate,
        "status": status,
        "products": products,
        "contact_no": contactNo,
        "cost": cost,
        "staff_name": staffName,
        "remarks": remarks,
        "renewal_type": renewalType,
        "renewal_status": renewalStatus,
        "follow_up_date": followUpDate,
    };
}
