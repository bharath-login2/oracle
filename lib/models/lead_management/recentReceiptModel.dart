class RecentReceiptModel {
  Data? data;
  bool? status;
  String? message;

  RecentReceiptModel({this.data, this.status, this.message});

  RecentReceiptModel.fromJson(Map<String, dynamic> json) {
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
  List<ReceiptItem>? list;
  String? totalAmount;
  int? totalRecords;

  Data({this.list, this.totalAmount, this.totalRecords});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <ReceiptItem>[];
      json['list'].forEach((v) {
        list!.add(ReceiptItem.fromJson(v));
      });
    }
    totalAmount = json['total_amount']?.toString();
    totalRecords = json['total_records'] is int
        ? json['total_records']
        : int.tryParse(json['total_records']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    data['total_amount'] = totalAmount;
    data['total_records'] = totalRecords;
    return data;
  }
}

class ReceiptItem {
  String? id;
  String? clientId;
  String? masterId;
  String? receiptNumber;
  String? receiptDate;
  String? recieptAmount;
  String? createdAt;
  String? customerName;
  String? staffName;
  String? invoiceSerial;
  String? invoiceNumber;
  String? installmentId;
  String? renewalId;
  String? invType;
  String? isRenewed;
  String? createdName;
String? accountHead;
  ReceiptItem({
    this.id,
    this.clientId,
    this.masterId,
    this.receiptNumber,
    this.receiptDate,
    this.recieptAmount,
    this.createdAt,
    this.customerName,
    this.staffName,
    this.invoiceSerial,
    this.invoiceNumber,
    this.installmentId,
    this.renewalId,
    this.invType,
    this.isRenewed,
    this.createdName,
    this.accountHead,
  });

  ReceiptItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    masterId = json['master_id'];
    receiptNumber = json['receipt_number'];
    receiptDate = json['receipt_date'];
    recieptAmount = json['reciept_amount'];
    createdAt = json['created_at'];
    customerName = json['customer_name'];
    staffName = json['staff_name'];
    invoiceSerial = json['invoice_serial'];
    invoiceNumber = json['invoice_number'];
    installmentId = json['installment_id'];
    renewalId = json['renewal_id'];
    invType = json['inv_type'];
    isRenewed = json['is_renewed'];
    createdName = json['created_name'];
    accountHead = json['account_head'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_id'] = clientId;
    data['master_id'] = masterId;
    data['receipt_number'] = receiptNumber;
    data['receipt_date'] = receiptDate;
    data['reciept_amount'] = recieptAmount;
    data['created_at'] = createdAt;
    data['customer_name'] = customerName;
    data['staff_name'] = staffName;
    data['invoice_serial'] = invoiceSerial;
    data['invoice_number'] = invoiceNumber;
    data['installment_id'] = installmentId;
    data['renewal_id'] = renewalId;
    data['inv_type'] = invType;
    data['is_renewed'] = isRenewed;
    data['created_name'] = createdName;
    data['account_head'] = accountHead;
    return data;
  }
}