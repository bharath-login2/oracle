class SupplierDashboardResponse {
  bool? status;
  String? message;
  SupplierDashboardData? data;

  SupplierDashboardResponse({
    this.status,
    this.message,
    this.data,
  });

  SupplierDashboardResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? SupplierDashboardData.fromJson(json['data'])
        : null;
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

class SupplierDashboardData {
  String? supplierId;
  String? totalPurchase;
  String? availableToRedeem;
  String? totalBills;
    String? totalAdvance;
  List<RecentPurchase>? recentPurchases;

  SupplierDashboardData({
    this.supplierId,
    this.totalPurchase,
    this.availableToRedeem,
    this.totalBills,
    this.totalAdvance,
    this.recentPurchases,
  });

  SupplierDashboardData.fromJson(Map<String, dynamic> json) {
    supplierId = json['supplier_id'];
    totalPurchase = json['total_purchase'];
    availableToRedeem = json['available_to_redeem'];
    totalBills = json['total_bills'];
    totalAdvance = json['total_advance'];
    if (json['recent_purchases'] != null) {
      recentPurchases = <RecentPurchase>[];
      json['recent_purchases'].forEach((v) {
        recentPurchases!.add(RecentPurchase.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['supplier_id'] = supplierId;
    data['total_purchase'] = totalPurchase;
    data['available_to_redeem'] = availableToRedeem;
    data['total_bills'] = totalBills;
    data['total_advance'] = totalAdvance;
    if (recentPurchases != null) {
      data['recent_purchases'] =
          recentPurchases!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RecentPurchase {
  String? billId;
  String? invoiceNo;
  String? billDate;
  String? totAmount;
  String? payableAmount;
  String? totalPaid;
  String? balanceAmount;

  RecentPurchase({
    this.billId,
    this.invoiceNo,
    this.billDate,
    this.totAmount,
    this.payableAmount,
    this.totalPaid,
    this.balanceAmount,
  });

  RecentPurchase.fromJson(Map<String, dynamic> json) {
    billId = json['bill_id'];
    invoiceNo = json['invoice_no'];
    billDate = json['bill_date'];
    totAmount = json['totAmount'];
    payableAmount = json['payable_amount'];
    totalPaid = json['total_paid'];
    balanceAmount = json['balance_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bill_id'] = billId;
    data['invoice_no'] = invoiceNo;
    data['bill_date'] = billDate;
    data['totAmount'] = totAmount;
    data['payable_amount'] = payableAmount;
    data['total_paid'] = totalPaid;
    data['balance_amount'] = balanceAmount;
    return data;
  }
}