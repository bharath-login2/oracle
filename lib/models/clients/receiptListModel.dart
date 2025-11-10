// To parse this JSON data, do
//
//     final receiptListModel = receiptListModelFromJson(jsonString);

import 'dart:convert';

ReceiptListModel receiptListModelFromJson(String str) => ReceiptListModel.fromJson(json.decode(str));

String receiptListModelToJson(ReceiptListModel data) => json.encode(data.toJson());

class ReceiptListModel {
    Data data;
    bool status;
    String message;

    ReceiptListModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ReceiptListModel.fromJson(Map<String, dynamic> json) => ReceiptListModel(
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
    String receiptSum;

    Data({
        required this.lists,
        required this.receiptSum,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        receiptSum: json["receipt_sum"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "receipt_sum": receiptSum,
    };
}

class ListElement {
    String id;
    String receiptNumber;
    String invoiceNumber;
    String receiptDate;
    String clientId;
    String customerName;
    String recieptAmount;
    String collectedStaff;
    String uploadedFile;
     String isVerified;
     String createdBy;
       String createdAt;

    ListElement({
        required this.id,
        required this.receiptNumber,
        required this.invoiceNumber,
        required this.receiptDate,
        required this.clientId,
        required this.customerName,
        required this.recieptAmount,
        required this.collectedStaff,
        required this.uploadedFile,
         required this.isVerified,
          required this.createdBy,
          required this.createdAt,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        receiptNumber: json["receipt_number"],
        invoiceNumber: json["invoice_number"],
        receiptDate: json["receipt_date"],
        clientId: json["client_id"],
        customerName: json["customer_name"],
        recieptAmount: json["reciept_amount"],
        collectedStaff: json["collected_staff"],
        uploadedFile: json["uploaded_file"],
         isVerified: json["is_verified"],
          createdBy: json["created_by"],
            createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "receipt_number": receiptNumber,
        "invoice_number": invoiceNumber,
        "receipt_date": receiptDate,
        "client_id": clientId,
        "customer_name": customerName,
        "reciept_amount": recieptAmount,
        "collected_staff": collectedStaff,
        "uploaded_file": uploadedFile,
          "is_verified": isVerified,
            "created_by": createdBy,
            "created_at": createdAt,
    };
}


