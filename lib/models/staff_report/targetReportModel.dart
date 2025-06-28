// To parse this JSON data, do
//
//     final targetDetails = targetDetailsFromJson(jsonString);

import 'dart:convert';

TargetDetails targetDetailsFromJson(String str) => TargetDetails.fromJson(json.decode(str));

String targetDetailsToJson(TargetDetails data) => json.encode(data.toJson());

class TargetDetails {
    bool status;
    String message;
    List<Target> data;

    TargetDetails({
        required this.status,
        required this.message,
        required this.data,
    });

    factory TargetDetails.fromJson(Map<String, dynamic> json) => TargetDetails(
        status: json["status"],
        message: json["message"],
        data: List<Target>.from(json["data"].map((x) => Target.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Target {
    String staffName;
    String recieptAmount;
    String groupName;
    DateTime receiptDate;
    String productName;
    String masterId;
     String receiptId;
     String receiptNumber;
     String clientId;
     String clientName;
       String taxInclude;


    Target({
        required this.staffName,
        required this.recieptAmount,
        required this.groupName,
        required this.receiptDate,
        required this.productName,
        required this.masterId,
        required this.receiptId,
        required this.receiptNumber,
        required this.clientId,
        required this.clientName,
          required this.taxInclude,
    });

    factory Target.fromJson(Map<String, dynamic> json) => Target(
        staffName: json["staff_name"]??"",
        recieptAmount: json["reciept_amount"]??"",
        groupName: json["group_name"]??"",
        receiptDate: DateTime.parse(json["receipt_date"]??""),
        productName: json["product_name"]??"",
        masterId: json["master_id"]??"",
        receiptId: json["receipt_id"]??"",
        receiptNumber: json["receipt_number"]??"",
        clientId: json["client_id"]??"",
        clientName: json["name"]??"",
        taxInclude: json["tax_include"]??"",
    );

    Map<String, dynamic> toJson() => {
        "staff_name": staffName,
        "reciept_amount": recieptAmount,
        "group_name": groupName,
        "receipt_date": "${receiptDate.year.toString().padLeft(4, '0')}-${receiptDate.month.toString().padLeft(2, '0')}-${receiptDate.day.toString().padLeft(2, '0')}",
        "product_name": productName,
        "master_id": masterId,
         "receipt_id": receiptId,
          "receipt_number": receiptNumber,
           "client_id": clientId,
            "name": clientName,
              "tax_include": taxInclude,
    };
}
