class PurchaseBillModel {
  final bool? status;
  final String? message;
  final List<PurchaseBillData>? data;

  PurchaseBillModel({
    this.status,
    this.message,
    this.data,
  });

  factory PurchaseBillModel.fromJson(Map<String, dynamic> json) {
    return PurchaseBillModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<PurchaseBillData>.from(
              json['data'].map((x) => PurchaseBillData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseBillData {
  final String? billId;
  final String? billNo;
  final String? billDate;
  final String? supplierName;
  final String? gst;
  final String? cgst;
  final String? sgst;
  final String? igst;
  final String? gstAmount;
  final String? itemTotal;
  final String? grandTotal;

  PurchaseBillData({
    this.billId,
    this.billNo,
    this.billDate,
    this.supplierName,
    this.gst,
    this.cgst,
    this.sgst,
    this.igst,
    this.gstAmount,
    this.itemTotal,
    this.grandTotal,
  });

  factory PurchaseBillData.fromJson(Map<String, dynamic> json) {
    return PurchaseBillData(
      billId: json['bill_id'],
      billNo: json['bill_no'],
      billDate: json['bill_date'],
      supplierName: json['supplier_name'],
      gst: json['gst'],
      cgst: json['cgst'],
      sgst: json['sgst'],
      igst: json['igst'],
      gstAmount: json['gst_amount'],
      itemTotal: json['item_total'],
      grandTotal: json['grand_total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bill_id': billId,
      'bill_no': billNo,
      'bill_date': billDate,
      'supplier_name': supplierName,
      'gst': gst,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'gst_amount': gstAmount,
      'item_total': itemTotal,
      'grand_total': grandTotal,
    };
  }

  // Helper getters for numeric conversions
  double? get gstPercentage => double.tryParse(gst ?? '');
  double? get cgstAmount => double.tryParse(cgst ?? '');
  double? get sgstAmount => double.tryParse(sgst ?? '');
  double? get igstAmount => double.tryParse(igst ?? '');
  double? get gstTotalAmount => double.tryParse(gstAmount ?? '');
  double? get itemTotalAmount => double.tryParse(itemTotal ?? '');
  double? get grandTotalAmount => double.tryParse(grandTotal ?? '');

  // Helper to check if GST is applicable
  bool get hasGst => (gstPercentage ?? 0) > 0;

  // Helper to get formatted grand total with 2 decimal places
  String get formattedGrandTotal {
    final amount = grandTotalAmount;
    if (amount != null) {
      return '${amount.toStringAsFixed(2)}';
    }
    return grandTotal ?? '0.00';
  }
}
