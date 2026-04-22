class GetArchievedInvoiceModel {
  Data? data;
  bool? status;
  String? message;

  GetArchievedInvoiceModel({this.data, this.status, this.message});

  GetArchievedInvoiceModel.fromJson(Map<String, dynamic> json) {
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
  Map<String, ArchievedInvoiceItem>? invoices;
  int? totalRecords;

  Data({this.invoices, this.totalRecords});

  Data.fromJson(Map<String, dynamic> json) {
    invoices = <String, ArchievedInvoiceItem>{};
    json.forEach((key, value) {
      if (key != 'total_records') {
        invoices![key] = ArchievedInvoiceItem.fromJson(value);
      }
    });
    totalRecords = json['total_records'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (invoices != null) {
      invoices!.forEach((key, value) {
        data[key] = value.toJson();
      });
    }
    data['total_records'] = totalRecords;
    return data;
  }
}

class ArchievedInvoiceItem {
  String? id;
  String? clientId;
  String? invoiceDate;
  String? invoiceSerial;
  String? invoiceNumber;
  String? subTotal;
  String? estimatedTax;
  String? discountAmount;
  String? totalPaidAmount;
  String? paymentStatus;
  String? paymentMode;
  String? customerName;
  String? createdBy;
  String? createdAt;
  String? staffName;
  String? hiddenStaffName;
  String? hiddenDate;

  ArchievedInvoiceItem({
    this.id,
    this.clientId,
    this.invoiceDate,
    this.invoiceSerial,
    this.invoiceNumber,
    this.subTotal,
    this.estimatedTax,
    this.discountAmount,
    this.totalPaidAmount,
    this.paymentStatus,
    this.paymentMode,
    this.customerName,
    this.createdBy,
    this.createdAt,
    this.staffName,
    this.hiddenStaffName,
    this.hiddenDate,
  });

  ArchievedInvoiceItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    invoiceDate = json['invoice_date'];
    invoiceSerial = json['invoice_serial'];
    invoiceNumber = json['invoice_number'];
    subTotal = json['sub_total'];
    estimatedTax = json['estimated_tax'];
    discountAmount = json['discount_amount'];
    totalPaidAmount = json['total_paid_amount'];
    paymentStatus = json['payment_status'];
    paymentMode = json['payment_mode'];
    customerName = json['customer_name'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    staffName = json['staff_name'];
    hiddenStaffName = json['hidden_staff_name'];
    hiddenDate = json['hidden_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_id'] = clientId;
    data['invoice_date'] = invoiceDate;
    data['invoice_serial'] = invoiceSerial;
    data['invoice_number'] = invoiceNumber;
    data['sub_total'] = subTotal;
    data['estimated_tax'] = estimatedTax;
    data['discount_amount'] = discountAmount;
    data['total_paid_amount'] = totalPaidAmount;
    data['payment_status'] = paymentStatus;
    data['payment_mode'] = paymentMode;
    data['customer_name'] = customerName;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['staff_name'] = staffName;
    data['hidden_staff_name'] = hiddenStaffName;
    data['hidden_date'] = hiddenDate;
    return data;
  }
}