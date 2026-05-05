class GetPurchaseOrderModel {
  bool? status;
  String? message;
  List<PurchaseOrderData>? data;

  GetPurchaseOrderModel({this.status, this.message, this.data});

  GetPurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PurchaseOrderData>[];
      json['data'].forEach((v) {
        data!.add(PurchaseOrderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseOrderData {
  String? poId;
  String? orderId;
  String? orderDate;
  String? supplierId;
  String? supplierName;
  String? estimatedAmt;
  String? advanceAmt;
  String? balanceAmt;
  String? billStatus;
  String? address;

  PurchaseOrderData({
    this.poId,
    this.orderId,
    this.orderDate,
    this.supplierId,
    this.supplierName,
    this.estimatedAmt,
    this.advanceAmt,
    this.balanceAmt,
    this.billStatus,
    this.address,
  });

  PurchaseOrderData.fromJson(Map<String, dynamic> json) {
    poId = json['po_id'];
    orderId = json['order_id'];
    orderDate = json['order_date'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    estimatedAmt = json['estimated_amt'];
    advanceAmt = json['advance_amt'];
    balanceAmt = json['balance_amt'];
    billStatus = json['bill_status'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['po_id'] = poId;
    data['order_id'] = orderId;
    data['order_date'] = orderDate;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['estimated_amt'] = estimatedAmt;
    data['advance_amt'] = advanceAmt;
    data['balance_amt'] = balanceAmt;
    data['bill_status'] = billStatus;
    data['address'] = address;
    return data;
  }
}