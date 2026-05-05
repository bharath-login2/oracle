class GetPurchaseReturnAddListModel {
  final bool status;
  final String message;
  final List<PurchaseReturnItem> data;

  GetPurchaseReturnAddListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetPurchaseReturnAddListModel.fromJson(Map<String, dynamic> json) {
    return GetPurchaseReturnAddListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<PurchaseReturnItem>.from(
              json['data'].map((x) => PurchaseReturnItem.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class PurchaseReturnItem {
  final String itemId;
  final String billId;
  final String supplierId;
  final String materialId;
  final String materialName;
  final String unitId;
  final String unitName;
  final String quantity;
  final String unitPrice;
  final String gst;
  final String gstAmount;
  final String totalAmount;

  PurchaseReturnItem({
    required this.itemId,
    required this.billId,
    required this.supplierId,
    required this.materialId,
    required this.materialName,
    required this.unitId,
    required this.unitName,
    required this.quantity,
    required this.unitPrice,
    required this.gst,
    required this.gstAmount,
    required this.totalAmount,
  });

  factory PurchaseReturnItem.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnItem(
      itemId: json['item_id']?.toString() ?? '',
      billId: json['bill_id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      materialId: json['material_id']?.toString() ?? '',
      materialName: json['material_name']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      unitName: json['unit_name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      gst: json['gst']?.toString() ?? '',
      gstAmount: json['gst_amount']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'bill_id': billId,
      'supplier_id': supplierId,
      'material_id': materialId,
      'material_name': materialName,
      'unit_id': unitId,
      'unit_name': unitName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'gst': gst,
      'gst_amount': gstAmount,
      'total_amount': totalAmount,
    };
  }
}