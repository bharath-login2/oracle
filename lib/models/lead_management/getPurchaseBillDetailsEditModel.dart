class GetPurchaseBillDetailsModel {
  bool? status;
  String? message;
  PurchaseBillData? data;

  GetPurchaseBillDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  GetPurchaseBillDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PurchaseBillData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PurchaseBillData {
  BillDetails? billDetails;
  PaymentDetails? paymentDetails;
  List<BillItem>? items;

  PurchaseBillData({
    this.billDetails,
    this.paymentDetails,
    this.items,
  });

  PurchaseBillData.fromJson(Map<String, dynamic> json) {
    billDetails = json['bill_details'] != null
        ? BillDetails.fromJson(json['bill_details'])
        : null;
    paymentDetails = json['payment_details'] != null
        ? PaymentDetails.fromJson(json['payment_details'])
        : null;
    if (json['items'] != null) {
      items = <BillItem>[];
      json['items'].forEach((v) {
        items!.add(BillItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (billDetails != null) {
      data['bill_details'] = billDetails!.toJson();
    }
    if (paymentDetails != null) {
      data['payment_details'] = paymentDetails!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BillDetails {
  String? purchaseBillId;
  String? billId;
  String? invoiceNo;
  String? orderId;
  String? requestId;
  String? supplierId;
  String? supplierName;
  String? paidDate;
  String? advanceAmountPaid;
  String? accountName;
  String? paymentMode;
  String? trReferenceDate;
  String? trReferenceNo;
  String? transactionRemarks;
  String? billDate;
  String? totalAmount;
  String? paidAmount;
  String? paymentMethod;
  String? remarks;
  String? billFile;
  String? tdsAmount;
  String? invoiceDate;
  String? taxType;
  String? billAddress;

  BillDetails({
    this.purchaseBillId,
    this.billId,
    this.invoiceNo,
    this.orderId,
    this.requestId,
    this.supplierId,
    this.supplierName,
    this.paidDate,
    this.advanceAmountPaid,
    this.accountName,
    this.paymentMode,
    this.trReferenceDate,
    this.trReferenceNo,
    this.transactionRemarks,
    this.billDate,
    this.totalAmount,
    this.paidAmount,
    this.paymentMethod,
    this.remarks,
    this.billFile,
    this.tdsAmount,
    this.invoiceDate,
    this.taxType,
    this.billAddress,
  });

  BillDetails.fromJson(Map<String, dynamic> json) {
    purchaseBillId = json['purchase_bill_id'];
    billId = json['bill_id'];
    invoiceNo = json['invoice_no'];
    orderId = json['order_id'];
    requestId = json['request_id'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    paidDate = json['paid_date'];
    advanceAmountPaid = json['advance_amount_paid'];
    accountName = json['account_name'];
    paymentMode = json['payment_mode'];
    trReferenceDate = json['tr_reference_date'];
    trReferenceNo = json['tr_reference_no'];
    transactionRemarks = json['transaction_remarks'];
    billDate = json['bill_date'];
    totalAmount = json['total_amount'];
    paidAmount = json['paid_amount'];
    paymentMethod = json['payment_method'];
    remarks = json['remarks'];
    billFile = json['bill_file'];
    tdsAmount = json['tds_amount'];
    invoiceDate = json['invoice_date'];
    taxType = json['tax_type'];
    billAddress = json['bill_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['purchase_bill_id'] = purchaseBillId;
    data['bill_id'] = billId;
    data['invoice_no'] = invoiceNo;
    data['order_id'] = orderId;
    data['request_id'] = requestId;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['paid_date'] = paidDate;
    data['advance_amount_paid'] = advanceAmountPaid;
    data['account_name'] = accountName;
    data['payment_mode'] = paymentMode;
    data['tr_reference_date'] = trReferenceDate;
    data['tr_reference_no'] = trReferenceNo;
    data['transaction_remarks'] = transactionRemarks;
    data['bill_date'] = billDate;
    data['total_amount'] = totalAmount;
    data['paid_amount'] = paidAmount;
    data['payment_method'] = paymentMethod;
    data['remarks'] = remarks;
    data['bill_file'] = billFile;
    data['tds_amount'] = tdsAmount;
    data['invoice_date'] = invoiceDate;
    data['tax_type'] = taxType;
    data['bill_address'] = billAddress;
    return data;
  }
}

class PaymentDetails {
  String? paidDate;
  String? advanceAmountPaid;
  String? accountName;
  String? paymentMode;
  String? trReferenceDate;
  String? trReferenceNo;
  String? transactionRemarks;

  PaymentDetails({
    this.paidDate,
    this.advanceAmountPaid,
    this.accountName,
    this.paymentMode,
    this.trReferenceDate,
    this.trReferenceNo,
    this.transactionRemarks,
  });

  PaymentDetails.fromJson(Map<String, dynamic> json) {
    paidDate = json['paid_date'];
    advanceAmountPaid = json['advance_amount_paid'];
    accountName = json['account_name'];
    paymentMode = json['payment_mode'];
    trReferenceDate = json['tr_reference_date'];
    trReferenceNo = json['tr_reference_no'];
    transactionRemarks = json['transaction_remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['paid_date'] = paidDate;
    data['advance_amount_paid'] = advanceAmountPaid;
    data['account_name'] = accountName;
    data['payment_mode'] = paymentMode;
    data['tr_reference_date'] = trReferenceDate;
    data['tr_reference_no'] = trReferenceNo;
    data['transaction_remarks'] = transactionRemarks;
    return data;
  }
}

class BillItem {
  String? itemId;
  String? materialId;
  String? materialName;
  String? unitId;
  String? unitName;
  String? quantity;
  String? unitPrice;
  String? gst;
  String? gstAmount;
  String? totalAmount;

  BillItem({
    this.itemId,
    this.materialId,
    this.materialName,
    this.unitId,
    this.unitName,
    this.quantity,
    this.unitPrice,
    this.gst,
    this.gstAmount,
    this.totalAmount,
  });

  BillItem.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    materialId = json['material_id'];
    materialName = json['material_name'];
    unitId = json['unit_id'];
    unitName = json['unit_name'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    gst = json['gst'];
    gstAmount = json['gst_amount'];
    totalAmount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['item_id'] = itemId;
    data['material_id'] = materialId;
    data['material_name'] = materialName;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['quantity'] = quantity;
    data['unit_price'] = unitPrice;
    data['gst'] = gst;
    data['gst_amount'] = gstAmount;
    data['total_amount'] = totalAmount;
    return data;
  }
}