class GetCompanyInvoiceModel {
  Data? data;
  bool? status;
  String? message;

  GetCompanyInvoiceModel({this.data, this.status, this.message});

  GetCompanyInvoiceModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.toJson();
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  List<InvoiceItem>? lists;
  String? totalInvoiceAmount;
  String? totalInvoicePaid;
  String? balanceAmount;
  int? totalRecords;

  Data({
    this.lists,
    this.totalInvoiceAmount,
    this.totalInvoicePaid,
    this.balanceAmount,
    this.totalRecords,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['lists'] != null) {
      lists = <InvoiceItem>[];
      json['lists'].forEach((v) {
        lists!.add(InvoiceItem.fromJson(v));
      });
    }
    totalInvoiceAmount = json['total_invoice_amount'];
    totalInvoicePaid = json['total_invoice_paid'];
    balanceAmount = json['balance_amount'];
    totalRecords = json['total_records'] is int
        ? json['total_records']
        : int.tryParse(json['total_records']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lists != null) {
      data['lists'] = lists!.map((v) => v.toJson()).toList();
    }
    data['total_invoice_amount'] = totalInvoiceAmount;
    data['total_invoice_paid'] = totalInvoicePaid;
    data['balance_amount'] = balanceAmount;
    data['total_records'] = totalRecords;
    return data;
  }
}

class InvoiceItem {
  String? id;
  String? renewalId;
  String? installmentId;
  String? invType;
  String? invoiceNumber;
  String? invoiceDate;
  String? createdAt;
  String? customerName;
  String? paymentMode;
  String? isRenewed;
  String? totalAmount;
  String? totalPaid;
  String? balance;
  String? status;
  bool? isPaid;
  String? renewalType;
  String? createdBy;
  List<Product>? products;
  String? clientId;

  InvoiceItem({
    this.id,
    this.renewalId,
    this.installmentId,
    this.invType,
    this.invoiceNumber,
    this.invoiceDate,
    this.createdAt,
    this.customerName,
    this.paymentMode,
    this.isRenewed,
    this.totalAmount,
    this.totalPaid,
    this.balance,
    this.status,
    this.isPaid,
    this.renewalType,
    this.createdBy,
    this.products,
    this.clientId,
  });

  InvoiceItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    renewalId = json['renewal_id'];
    installmentId = json['installment_id'];
    invType = json['inv_type'];
    invoiceNumber = json['invoice_number'];
    invoiceDate = json['invoice_date'];
    createdAt = json['created_at'];
    customerName = json['customer_name'];
    paymentMode = json['payment_mode'];
    isRenewed = json['is_renewed'];
    totalAmount = json['total_amount'];
    totalPaid = json['total_paid'];
    balance = json['balance'];
    status = json['status'];
    isPaid = json['is_paid'];
    renewalType = json['renewal_type'];
    createdBy = json['created_by'];
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
    clientId = json['client_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['renewal_id'] = renewalId;
    data['installment_id'] = installmentId;
    data['inv_type'] = invType;
    data['invoice_number'] = invoiceNumber;
    data['invoice_date'] = invoiceDate;
    data['created_at'] = createdAt;
    data['customer_name'] = customerName;
    data['payment_mode'] = paymentMode;
    data['is_renewed'] = isRenewed;
    data['total_amount'] = totalAmount;
    data['total_paid'] = totalPaid;
    data['balance'] = balance;
    data['status'] = status;
    data['is_paid'] = isPaid;
    data['renewal_type'] = renewalType;
    data['created_by'] = createdBy;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['client_id'] = clientId;
    return data;
  }
}

class Product {
  String? productId;
  String? qty;
  String? amount;
  String? productName;

  Product({
    this.productId,
    this.qty,
    this.amount,
    this.productName,
  });

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    qty = json['qty'];
    amount = json['amount'];
    productName = json['product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['qty'] = qty;
    data['amount'] = amount;
    data['product_name'] = productName;
    return data;
  }
}
