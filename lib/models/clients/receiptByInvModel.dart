class ReceiptByInvModel {
  Data? data;
  bool? status;
  String? message;

  ReceiptByInvModel({this.data, this.status, this.message});

  ReceiptByInvModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  List<Lists>? lists;
  String? receiptSum;

  Data({this.lists, this.receiptSum});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['lists'] != null) {
      lists = <Lists>[];
      json['lists'].forEach((v) {
        lists!.add(new Lists.fromJson(v));
      });
    }
    receiptSum = json['receipt_sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lists != null) {
      data['lists'] = this.lists!.map((v) => v.toJson()).toList();
    }
    data['receipt_sum'] = this.receiptSum;
    return data;
  }
}

class Lists {
  String? id;
  String? receiptNumber;
  String? invoiceNumber;
  String? receiptDate;
  String? clientId;
  String? customerName;
  String? recieptAmount;
  String? collectedStaff;
  String? uploadedFile;

  Lists(
      {this.id,
        this.receiptNumber,
        this.invoiceNumber,
        this.receiptDate,
        this.clientId,
        this.customerName,
        this.recieptAmount,
        this.collectedStaff,
        this.uploadedFile});

  Lists.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    receiptNumber = json['receipt_number'];
    invoiceNumber = json['invoice_number'];
    receiptDate = json['receipt_date'];
    clientId = json['client_id'];
    customerName = json['customer_name'];
    recieptAmount = json['reciept_amount'];
    collectedStaff = json['collected_staff'];
    uploadedFile = json['uploaded_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['receipt_number'] = receiptNumber;
    data['invoice_number'] = invoiceNumber;
    data['receipt_date'] = receiptDate;
    data['client_id'] = clientId;
    data['customer_name'] = customerName;
    data['reciept_amount'] = recieptAmount;
    data['collected_staff'] = collectedStaff;
    data['uploaded_file'] = uploadedFile;
    return data;
  }
}