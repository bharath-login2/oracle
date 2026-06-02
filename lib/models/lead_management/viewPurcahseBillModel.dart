class ViewPurchaseBillResponse {
  bool? status;
  String? message;
  PurchaseBillData? data;

  ViewPurchaseBillResponse({
    this.status,
    this.message,
    this.data,
  });

  ViewPurchaseBillResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PurchaseBillData.fromJson(json['data']) : null;
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

class PurchaseBillData {
  String? purchaseBillId;
  String? billId;
  String? billNo;
  String? billDate;
  String? invoiceNo;
  String? invoiceDate;
  String? requestId;
  String? orderId;
  String? supplierId;
  String? supplierName;
  String? paidAmount;
  String? referenceNo;
  String? accountName;
  String? subTotal;
    String? purchasePrice;
  String? gstAmt;
  String? discount;
  String? tdsAmt;
  String? payableAmount;
  String? paidDate;
  String? balancePaidAmount;
  String? paymentMode;
  String? trReferenceNo;
  String? trReferenceDate;
  String? transactionRemarks;
    String? paymentStatus;
  String? createddt;
  String? file;
  List<PurchaseBillItem>? items;

  PurchaseBillData({
    this.purchaseBillId,
    this.billId,
    this.billNo,
    this.billDate,
    this.invoiceNo,
    this.invoiceDate,
    this.requestId,
    this.orderId,
    this.supplierId,
    this.supplierName,
    this.paidAmount,
    this.referenceNo,
    this.accountName,
    this.subTotal,
     this.purchasePrice,
    this.gstAmt,
    this.discount,
    this.tdsAmt,
    this.payableAmount,
    this.paidDate,
    this.balancePaidAmount,
    this.paymentMode,
    this.trReferenceNo,
    this.trReferenceDate,
    this.transactionRemarks,
      this.paymentStatus,
    this.createddt,
    this.file,
    this.items,
  });

  PurchaseBillData.fromJson(Map<String, dynamic> json) {
    purchaseBillId = json['purchase_bill_id']?.toString();
    billId = json['bill_id'];
    billNo = json['bill_no'];
    billDate = json['bill_date'];
    invoiceNo = json['invoice_no'];
    invoiceDate = json['invoice_date'];
    requestId = json['request_id'];
    orderId = json['order_id'];
    supplierId = json['supplier_id']?.toString();
    supplierName = json['supplier_name'];
    paidAmount = json['paid_amount']?.toString();
    referenceNo = json['reference_no'];
    accountName = json['account_name'];
    subTotal = json['sub_total']?.toString();
    purchasePrice = json['purchase_price']?.toString();
    gstAmt = json['gst_amt']?.toString();
    discount = json['discount']?.toString();
    tdsAmt = json['tds_amt']?.toString();
    payableAmount = json['payable_amount']?.toString();
    paidDate = json['paid_date'];
    balancePaidAmount = json['balance_paid_amount']?.toString();
    paymentMode = json['payment_mode'];
    trReferenceNo = json['tr_reference_no'];
    trReferenceDate = json['tr_reference_date'];
    transactionRemarks = json['transaction_remarks'];
    paymentStatus = json['payment_status'];
    createddt = json['createddt'];
    file = json['file'];
    if (json['items'] != null) {
      items = <PurchaseBillItem>[];
      json['items'].forEach((v) {
        items!.add(PurchaseBillItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['purchase_bill_id'] = purchaseBillId;
    data['bill_id'] = billId;
    data['bill_no'] = billNo;
    data['bill_date'] = billDate;
    data['invoice_no'] = invoiceNo;
    data['invoice_date'] = invoiceDate;
    data['request_id'] = requestId;
    data['order_id'] = orderId;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['paid_amount'] = paidAmount;
    data['reference_no'] = referenceNo;
    data['account_name'] = accountName;
    data['sub_total'] = subTotal;
     data['purchase_price'] = purchasePrice;
    data['gst_amt'] = gstAmt;
    data['discount'] = discount;
    data['tds_amt'] = tdsAmt;
    data['payable_amount'] = payableAmount;
    data['paid_date'] = paidDate;
    data['balance_paid_amount'] = balancePaidAmount;
    data['payment_mode'] = paymentMode;
    data['tr_reference_no'] = trReferenceNo;
    data['tr_reference_date'] = trReferenceDate;
    data['transaction_remarks'] = transactionRemarks;
    data['payment_status'] = paymentStatus;
    data['createddt'] = createddt;
    data['file'] = file;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseBillItem {
  String? itemId;
  String? materialId;
  String? productName;
  String? unitId;
  String? unitName;
  String? quantity;
  String? unitPrice;
  String? gst;
  String? gstAmt;
  String? itemTotal;

  PurchaseBillItem({
    this.itemId,
    this.materialId,
    this.productName,
    this.unitId,
    this.unitName,
    this.quantity,
    this.unitPrice,
    this.gst,
    this.gstAmt,
    this.itemTotal,
  });

  PurchaseBillItem.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id']?.toString();
    materialId = json['material_id']?.toString();
    productName = json['product_name'];
    unitId = json['unit_id']?.toString();
    unitName = json['unit_name'];
    quantity = json['quantity']?.toString();
    unitPrice = json['unit_price']?.toString();
    gst = json['gst']?.toString();
    gstAmt = json['gst_amt']?.toString();
    itemTotal = json['item_total']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['material_id'] = materialId;
    data['product_name'] = productName;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['quantity'] = quantity;
    data['unit_price'] = unitPrice;
    data['gst'] = gst;
    data['gst_amt'] = gstAmt;
    data['item_total'] = itemTotal;
    return data;
  }
}