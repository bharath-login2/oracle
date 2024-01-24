class PendingInvoiceListModel {
  Data? data;
  bool? status;
  String? message;

  PendingInvoiceListModel({this.data, this.status, this.message});

  PendingInvoiceListModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  List<Lists>? lists;
  String? totalInvoiceAmount;
  String? totalInvoicePaid;
  String? balanceAmount;

  Data(
      {this.lists,
        this.totalInvoiceAmount,
        this.totalInvoicePaid,
        this.balanceAmount});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['lists'] != null) {
      lists = <Lists>[];
      json['lists'].forEach((v) {
        lists!.add(Lists.fromJson(v));
      });
    }
    totalInvoiceAmount = json['total_invoice_amount'];
    totalInvoicePaid = json['total_invoice_paid'];
    balanceAmount = json['balance_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lists != null) {
      data['lists'] = lists!.map((v) => v.toJson()).toList();
    }
    data['total_invoice_amount'] = totalInvoiceAmount;
    data['total_invoice_paid'] = totalInvoicePaid;
    data['balance_amount'] = balanceAmount;
    return data;
  }
}

class Lists {
  String? id;
  String? invoiceNumber;
  String? invoiceDate;
  String? customerName;
  String? paymentMode;
  String? totalAmount;
  String? totalPaid;
  String? balance;
  String? status;
  bool? isPaid;
  String? receiptId;
  String? recieptAmount;
  String? clientId;

  Lists(
      {this.id,
        this.invoiceNumber,
        this.invoiceDate,
        this.customerName,
        this.paymentMode,
        this.totalAmount,
        this.totalPaid,
        this.balance,
        this.status,
        this.isPaid,
        this.receiptId,
        this.recieptAmount,
        this.clientId});

  Lists.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceNumber = json['invoice_number'];
    invoiceDate = json['invoice_date'];
    customerName = json['customer_name'];
    paymentMode = json['payment_mode'];
    totalAmount = json['total_amount'];
    totalPaid = json['total_paid'];
    balance = json['balance'];
    status = json['status'];
    isPaid = json['is_paid'];
    receiptId = json['receipt_id'];
    recieptAmount = json['reciept_amount'];
    clientId = json['client_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['invoice_number'] = invoiceNumber;
    data['invoice_date'] = invoiceDate;
    data['customer_name'] = customerName;
    data['payment_mode'] = paymentMode;
    data['total_amount'] = totalAmount;
    data['total_paid'] = totalPaid;
    data['balance'] = balance;
    data['status'] = status;
    data['is_paid'] = isPaid;
    data['receipt_id'] = receiptId;
    data['reciept_amount'] = recieptAmount;
    data['client_id'] = clientId;
    return data;
  }
}