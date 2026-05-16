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
  List<BillItem>? items;

  PurchaseBillData({
    this.billDetails,
    this.items,
  });

  PurchaseBillData.fromJson(Map<String, dynamic> json) {
    billDetails = json['bill_details'] != null
        ? BillDetails.fromJson(json['bill_details'])
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
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BillDetails {
  String? purchaseBillId;
  String? billId;
  String? orderId;
  String? requestId;
  String? supplierId;
  String? supplierName;
  String? billDate;
  String? totalAmount;
  String? paidAmount;
  String? paymentMethod;

  BillDetails({
    this.purchaseBillId,
    this.billId,
    this.orderId,
    this.requestId,
    this.supplierId,
    this.supplierName,
    this.billDate,
    this.totalAmount,
    this.paidAmount,
    this.paymentMethod,
  });

  BillDetails.fromJson(Map<String, dynamic> json) {
    purchaseBillId = json['purchase_bill_id'];
    billId = json['bill_id'];
    orderId = json['order_id'];
    requestId = json['request_id'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    billDate = json['bill_date'];
    totalAmount = json['total_amount'];
    paidAmount = json['paid_amount'];
    paymentMethod = json['payment_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['purchase_bill_id'] = purchaseBillId;
    data['bill_id'] = billId;
    data['order_id'] = orderId;
    data['request_id'] = requestId;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['bill_date'] = billDate;
    data['total_amount'] = totalAmount;
    data['paid_amount'] = paidAmount;
    data['payment_method'] = paymentMethod;
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