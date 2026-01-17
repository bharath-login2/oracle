// To parse this JSON data, do
//
//     final invoiceListModel = invoiceListModelFromJson(jsonString);

import 'dart:convert';

InvoiceListModel invoiceListModelFromJson(String str) =>
    InvoiceListModel.fromJson(json.decode(str));

class InvoiceListModel {
  Data data;
  bool status;
  String message;

  InvoiceListModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory InvoiceListModel.fromJson(Map<String, dynamic> json) =>
      InvoiceListModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );
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
        lists: List<ListElement>.from(
            json["lists"].map((x) => ListElement.fromJson(x))),
        totalInvoiceAmount: json["total_invoice_amount"],
        totalInvoicePaid: json["total_invoice_paid"],
        balanceAmount: json["balance_amount"],
      );
}

class ListElement {
  String id;
  String invType;
  String renewalId;
  String renewalType;
  String installmentId;
  String invoiceNumber;
  String invoiceDate;
  String customerName;
  String paymentMode;
  String totalAmount;
  String totalPaid;
  String balance;
  String status;
  bool isPaid;
  String clientId;
  List<Product> products;
   String gstinvoiceCreated;
    String isHidden;

  ListElement({
    required this.id,
    required this.invType,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.paymentMode,
    required this.totalAmount,
    required this.totalPaid,
    required this.balance,
    required this.status,
    required this.isPaid,
    required this.clientId,
    required this.renewalId,
    required this.renewalType,
    required this.installmentId,
    required this.products,
      required this.gstinvoiceCreated,
         required this.isHidden,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        invType: json["inv_type"],
        invoiceNumber: json["invoice_number"],
        invoiceDate: json["invoice_date"],
        customerName: json["customer_name"],
        paymentMode: json["payment_mode"],
        totalAmount: json["total_amount"],
        totalPaid: json["total_paid"],
        balance: json["balance"],
        status: json["status"],
        isPaid: json["is_paid"],
        clientId: json["client_id"],
        renewalId: json["renewal_id"],
        renewalType: json["renewal_id"],
        installmentId: json["installment_id"],
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x))),
             gstinvoiceCreated: json["gst_invoice_created"],
          isHidden: json["is_hidden"],
      );
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
