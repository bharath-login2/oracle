// To parse this JSON data, do
//
//     final mainClientDetailsModel = mainClientDetailsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

MainClientDetailsModel mainClientDetailsModelFromJson(String str) => MainClientDetailsModel.fromJson(json.decode(str));

String mainClientDetailsModelToJson(MainClientDetailsModel data) => json.encode(data.toJson());

class MainClientDetailsModel {
    bool status;
    String message;
    Data data;

    MainClientDetailsModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory MainClientDetailsModel.fromJson(Map<String, dynamic> json) => MainClientDetailsModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String id;
    String name;
    String emailId;
    String contactNo;
    String address;
    String pincode;
    String gstNum;
    String postOffice;
    String totalInvoiceAmount;
    String totalReceiptAmount;
    List<Invoice> invoice;
    List<Receipt> receipts;

    Data({
        required this.id,
        required this.name,
        required this.emailId,
        required this.contactNo,
        required this.address,
        required this.pincode,
        required this.gstNum,
        required this.postOffice,
        required this.totalInvoiceAmount,
        required this.totalReceiptAmount,
        required this.invoice,
        required this.receipts,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        emailId: json["email_id"],
        contactNo: json["contact_no"],
        address: json["address"],
        pincode: json["pincode"],
        gstNum: json["gst_num"],
        postOffice: json["post_office"],
        totalInvoiceAmount: json["total_invoice_amount"],
        totalReceiptAmount: json["total_receipt_amount"],
        invoice: List<Invoice>.from(json["invoice"].map((x) => Invoice.fromJson(x))),
        receipts: List<Receipt>.from(json["receipts"].map((x) => Receipt.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email_id": emailId,
        "contact_no": contactNo,
        "address": address,
        "pincode": pincode,
        "gst_num": gstNum,
        "post_office": postOffice,
        "total_invoice_amount": totalInvoiceAmount,
        "total_receipt_amount": totalReceiptAmount,
        "invoice": List<dynamic>.from(invoice.map((x) => x.toJson())),
        "receipts": List<dynamic>.from(receipts.map((x) => x.toJson())),
    };
}

class Invoice {
    String invid;
    String invoiceNumber;
    String invoiceDate;
    String status;
    String totalAmount;
    String paidAmount;
    String balanceAmount;
    String paymentMethod;
    bool isPaid;

    Invoice({
        required this.invid,
        required this.invoiceNumber,
        required this.invoiceDate,
        required this.status,
        required this.totalAmount,
        required this.paidAmount,
        required this.balanceAmount,
        required this.paymentMethod,
        required this.isPaid,
    });

    factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invid: json["invid"],
        invoiceNumber: json["invoiceNumber"],
        invoiceDate: json["invoiceDate"],
        status: json["status"],
        totalAmount: json["totalAmount"],
        paidAmount: json["paidAmount"],
        balanceAmount: json["balanceAmount"],
        paymentMethod: json["paymentMethod"],
        isPaid: json["isPaid"],
    );

    Map<String, dynamic> toJson() => {
        "invid": invid,
        "invoiceNumber": invoiceNumber,
        "invoiceDate": invoiceDate,
        "status": status,
        "totalAmount": totalAmount,
        "paidAmount": paidAmount,
        "balanceAmount": balanceAmount,
        "paymentMethod": paymentMethod,
        "isPaid": isPaid,
    };
}

class Receipt {
    String receiptId;
    String receiptNumber;
    String invoiceNumber;
    String receiptDate;
    String paidAmount;
    String paymentMethod;
    String collectedBy;
    String uploadedFile;

    Receipt({
        required this.receiptId,
        required this.receiptNumber,
        required this.invoiceNumber,
        required this.receiptDate,
        required this.paidAmount,
        required this.paymentMethod,
        required this.collectedBy,
        required this.uploadedFile,
    });

    factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        receiptId: json["receiptId"],
        receiptNumber: json["receiptNumber"],
        invoiceNumber: json["invoiceNumber"],
        receiptDate: json["receiptDate"],
        paidAmount: json["paidAmount"],
        paymentMethod: json["paymentMethod"],
        collectedBy: json["collectedBy"],
        uploadedFile: json["uploaded_file"],
    );

    Map<String, dynamic> toJson() => {
        "receiptId": receiptId,
        "receiptNumber": receiptNumber,
        "invoiceNumber": invoiceNumber,
        "receiptDate": receiptDate,
        "paidAmount": paidAmount,
        "paymentMethod": paymentMethod,
        "collectedBy": collectedBy,
        "uploaded_file": uploadedFile,
    };
}
