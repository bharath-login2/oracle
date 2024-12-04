// To parse this JSON data, do
//
//     final pendingInvoiceListModel = pendingInvoiceListModelFromJson(jsonString);

import 'dart:convert';

PendingInvoiceListModel pendingInvoiceListModelFromJson(String str) => PendingInvoiceListModel.fromJson(json.decode(str));

String pendingInvoiceListModelToJson(PendingInvoiceListModel data) => json.encode(data.toJson());

class PendingInvoiceListModel {
    Data data;
    bool status;
    String message;

    PendingInvoiceListModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory PendingInvoiceListModel.fromJson(Map<String, dynamic> json) => PendingInvoiceListModel(
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
    String totalInvoiceAmount;
    String totalInvoicePaid;
    String balanceAmount;

    Data({
        required this.lists,
        required this.totalInvoiceAmount,
        required this.totalInvoicePaid,
        required this.balanceAmount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        totalInvoiceAmount: json["total_invoice_amount"],
        totalInvoicePaid: json["total_invoice_paid"],
        balanceAmount: json["balance_amount"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "total_invoice_amount": totalInvoiceAmount,
        "total_invoice_paid": totalInvoicePaid,
        "balance_amount": balanceAmount,
    };
}

class ListElement {
    String id;
    String invoiceNumber;
    String invoiceDate;
    String customerName;
    String paymentMode;
    String totalAmount;
    String totalPaid;
    String balance;
    String status;
    bool isPaid;
    String receiptId;
    String recieptAmount;
    String clientId;
    List<Product> products;

    ListElement({
        required this.id,
        required this.invoiceNumber,
        required this.invoiceDate,
        required this.customerName,
        required this.paymentMode,
        required this.totalAmount,
        required this.totalPaid,
        required this.balance,
        required this.status,
        required this.isPaid,
        required this.receiptId,
        required this.recieptAmount,
        required this.clientId,
        required this.products,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        invoiceNumber: json["invoice_number"],
        invoiceDate: json["invoice_date"],
        customerName: json["customer_name"],
        paymentMode: json["payment_mode"],
        totalAmount: json["total_amount"],
        totalPaid: json["total_paid"],
        balance: json["balance"],
        status: json["status"],
        isPaid: json["is_paid"],
        receiptId: json["receipt_id"],
        recieptAmount: json["reciept_amount"],
        clientId: json["client_id"],
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_number": invoiceNumber,
        "invoice_date": invoiceDate,
        "customer_name": customerName,
        "payment_mode": paymentMode,
        "total_amount": totalAmount,
        "total_paid": totalPaid,
        "balance": balance,
        "status": status,
        "is_paid": isPaid,
        "receipt_id": receiptId,
        "reciept_amount": recieptAmount,
        "client_id": clientId,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
    };
}

class Product {
    String productId;
    String qty;
    String amount;
    String productName;

    Product({
        required this.productId,
        required this.qty,
        required this.amount,
        required this.productName,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json["product_id"],
        qty: json["qty"],
        amount: json["amount"],
        productName: json["product_name"],
    );

    Map<String, dynamic> toJson() => {
        "product_id": productId,
        "qty": qty,
        "amount": amount,
        "product_name": productName,
    };
}
