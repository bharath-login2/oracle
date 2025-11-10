import 'dart:convert';

InvoiceListModelGST invoiceListModelFromJson(String str) =>
    InvoiceListModelGST.fromJson(json.decode(str));

class InvoiceListModelGST {
  Data data;
  bool status;
  String message;

  InvoiceListModelGST({
    required this.data,
    required this.status,
    required this.message,
  });

  factory InvoiceListModelGST.fromJson(Map<String, dynamic> json) =>
      InvoiceListModelGST(
        data: Data.fromJson(json["data"] ?? {}),
        status: json["status"] ?? false,
        message: json["message"]?.toString() ?? '',
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
        lists: json["lists"] == null
            ? []
            : List<ListElement>.from(
                json["lists"].map((x) => ListElement.fromJson(x))),
        totalInvoiceAmount: json["total_invoice_amount"]?.toString() ?? '0',
        totalInvoicePaid: json["total_invoice_paid"]?.toString() ?? '0',
        balanceAmount: json["balance_amount"]?.toString() ?? '0',
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
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"]?.toString() ?? '',
        invType: json["inv_type"]?.toString() ?? '',
        invoiceNumber: json["invoice_number"]?.toString() ?? '',
        invoiceDate: json["invoice_date"]?.toString() ?? '',
        customerName: json["customer_name"]?.toString() ?? '',
        paymentMode: json["payment_mode"]?.toString() ?? '',
        totalAmount: json["total_amount"]?.toString() ?? '0',
        totalPaid: json["total_paid"]?.toString() ?? '0',
        balance: json["balance"]?.toString() ?? '0',
        status: json["status"]?.toString() ?? '',
        isPaid: json["is_paid"] ?? false,
        clientId: json["client_id"]?.toString() ?? '',
        renewalId: json["renewal_id"]?.toString() ?? '',
        renewalType: json["renewal_type"]?.toString() ?? '',
        installmentId: json["installment_id"]?.toString() ?? '',
        gstinvoiceCreated: json["gst_invoice_created"]?.toString() ?? '',
        products: json["products"] == null
            ? []
            : List<Product>.from(
                json["products"].map((x) => Product.fromJson(x))),
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
        productId: json["product_id"]?.toString() ?? '',
        qty: json["qty"]?.toString() ?? '0',
        amount: json["amount"]?.toString() ?? '0',
        productName: json["product_name"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "qty": qty,
        "amount": amount,
        "product_name": productName,
      };
}
