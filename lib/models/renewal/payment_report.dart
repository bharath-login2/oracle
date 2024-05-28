// To parse this JSON data, do
//
//     final paymentReportModel = paymentReportModelFromJson(jsonString);

import 'dart:convert';

PaymentReportModel paymentReportModelFromJson(String str) => PaymentReportModel.fromJson(json.decode(str));

String paymentReportModelToJson(PaymentReportModel data) => json.encode(data.toJson());

class PaymentReportModel {
    Data data;
    bool status;
    String message;

    PaymentReportModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory PaymentReportModel.fromJson(Map<String, dynamic> json) => PaymentReportModel(
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
    String totalAmount;
    String totalPaid;
    String balanceAmount;

    Data({
        required this.lists,
        required this.recordCount,
        required this.totalAmount,
        required this.totalPaid,
        required this.balanceAmount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        recordCount: json["record_count"],
        totalAmount: json["total_amount"],
        totalPaid: json["total_paid"],
        balanceAmount: json["balance_amount"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "record_count": recordCount,
        "total_amount": totalAmount,
        "total_paid": totalPaid,
        "balance_amount": balanceAmount,
    };
}

class ListElement {
    String invoiceId;
    String invoiceNumber;
    String customerName;
    String customerId;
    String startDate;
    String endDate;
    bool isPaid;
    String products;
    String productId;
    String contactNo;
    String cost;
    String paymentMode;
    String totalInvoiceAmount;

    ListElement({
        required this.invoiceId,
        required this.invoiceNumber,
        required this.customerName,
        required this.customerId,
        required this.startDate,
        required this.endDate,
        required this.isPaid,
        required this.products,
        required this.productId,
        required this.contactNo,
        required this.cost,
        required this.paymentMode,
        required this.totalInvoiceAmount,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        invoiceId: json["invoice_id"],
        invoiceNumber: json["invoice_number"],
        customerName: json["customer_name"],
        customerId: json["customer_id"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        isPaid: json["is_paid"],
        products: json["products"],
        productId: json["product_id"],
        contactNo: json["contact_no"],
        cost: json["cost"],
        paymentMode: json["payment_mode"],
        totalInvoiceAmount: json["total_invoice_amount"],
    );

    Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "invoice_number": invoiceNumber,
        "customer_name": customerName,
        "customer_id": customerId,
        "start_date": startDate,
        "end_date": endDate,
        "is_paid": isPaid,
        "products": products,
        "product_id": productId,
        "contact_no": contactNo,
        "cost": cost,
        "payment_mode": paymentMode,
        "total_invoice_amount": totalInvoiceAmount,
    };
}
