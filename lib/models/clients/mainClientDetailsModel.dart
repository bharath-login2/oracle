class MainClientDetailsModel {
  bool? status;
  String? message;
  Data? data;

  MainClientDetailsModel({this.status, this.message, this.data});

  MainClientDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? name;
  String? contactNo;
  String? address;
  String? pincode;
  String? gstNum;
  String? postOffice;
  String? totalInvoiceAmount;
  String? totalReceiptAmount;
  List<Invoice>? invoice;
  List<Receipts>? receipts;

  Data(
      {this.id,
        this.name,
        this.contactNo,
        this.address,
        this.pincode,
        this.gstNum,
        this.postOffice,
        this.totalInvoiceAmount,
        this.totalReceiptAmount,
        this.invoice,
        this.receipts});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    contactNo = json['contact_no'];
    address = json['address'];
    pincode = json['pincode'];
    gstNum = json['gst_num'];
    postOffice = json['post_office'];
    totalInvoiceAmount = json['total_invoice_amount'];
    totalReceiptAmount = json['total_receipt_amount'];
    if (json['invoice'] != null) {
      invoice = <Invoice>[];
      json['invoice'].forEach((v) {
        invoice!.add(Invoice.fromJson(v));
      });
    }
    if (json['receipts'] != null) {
      receipts = <Receipts>[];
      json['receipts'].forEach((v) {
        receipts!.add(Receipts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['contact_no'] = contactNo;
    data['address'] = address;
    data['pincode'] = pincode;
    data['gst_num'] = gstNum;
    data['post_office'] = postOffice;
    data['total_invoice_amount'] = totalInvoiceAmount;
    data['total_receipt_amount'] = totalReceiptAmount;
    if (invoice != null) {
      data['invoice'] = invoice!.map((v) => v.toJson()).toList();
    }
    if (receipts != null) {
      data['receipts'] = receipts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Invoice {
  String? invid;
  String? invoiceNumber;
  String? invoiceDate;
  String? status;
  String? totalAmount;
  String? paidAmount;
  String? balanceAmount;
  String? paymentMethod;
  bool? isPaid;

  Invoice(
      {this.invid,
        this.invoiceNumber,
        this.invoiceDate,
        this.status,
        this.totalAmount,
        this.paidAmount,
        this.balanceAmount,
        this.paymentMethod,
        this.isPaid});

  Invoice.fromJson(Map<String, dynamic> json) {
    invid = json['invid'];
    invoiceNumber = json['invoiceNumber'];
    invoiceDate = json['invoiceDate'];
    status = json['status'];
    totalAmount = json['totalAmount'];
    paidAmount = json['paidAmount'];
    balanceAmount = json['balanceAmount'];
    paymentMethod = json['paymentMethod'];
    isPaid = json['isPaid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invid'] = invid;
    data['invoiceNumber'] = invoiceNumber;
    data['invoiceDate'] = invoiceDate;
    data['status'] = status;
    data['totalAmount'] = totalAmount;
    data['paidAmount'] = paidAmount;
    data['balanceAmount'] = balanceAmount;
    data['paymentMethod'] = paymentMethod;
    data['isPaid'] = isPaid;
    return data;
  }
}

class Receipts {
  String? receiptId;
  String? receiptNumber;
  String? invoiceNumber;
  String? receiptDate;
  String? paidAmount;
  String? paymentMethod;
  String? collectedBy;
  String? uploadedFile;

  Receipts(
      {this.receiptId,
        this.receiptNumber,
        this.invoiceNumber,
        this.receiptDate,
        this.paidAmount,
        this.paymentMethod,
        this.collectedBy,
        this.uploadedFile});

  Receipts.fromJson(Map<String, dynamic> json) {
    receiptId = json['receiptId'];
    receiptNumber = json['receiptNumber'];
    invoiceNumber = json['invoiceNumber'];
    receiptDate = json['receiptDate'];
    paidAmount = json['paidAmount'];
    paymentMethod = json['paymentMethod'];
    collectedBy = json['collectedBy'];
    uploadedFile = json['uploaded_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['receiptId'] = receiptId;
    data['receiptNumber'] = receiptNumber;
    data['invoiceNumber'] = invoiceNumber;
    data['receiptDate'] = receiptDate;
    data['paidAmount'] = paidAmount;
    data['paymentMethod'] = paymentMethod;
    data['collectedBy'] = collectedBy;
    data['uploaded_file'] = uploadedFile;
    return data;
  }
}