class GetPurchaseReturnModel {
  final bool status;
  final String message;
  final List<PurchaseReturn> data;

  GetPurchaseReturnModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetPurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    return GetPurchaseReturnModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<PurchaseReturn>.from(json['data'].map((x) => PurchaseReturn.fromJson(x)))
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

class PurchaseReturn {
  final String id;
  final String returnId;
  final String returnDate;
  final String billId;
  final String supplierId;
  final String totalRetQuantity;
  final String totalRetAmt;
  final String companyId;
  final String returnBy;
  final String status;
  final String supplierName;
  final String materialId;
  final String unitId;
  final String returnQuantity;
  final String unitPrice;
  final String productName;
  final String unitName;

  PurchaseReturn({
    required this.id,
    required this.returnId,
    required this.returnDate,
    required this.billId,
    required this.supplierId,
    required this.totalRetQuantity,
    required this.totalRetAmt,
    required this.companyId,
    required this.returnBy,
    required this.status,
    required this.supplierName,
    required this.materialId,
    required this.unitId,
    required this.returnQuantity,
    required this.unitPrice,
    required this.productName,
    required this.unitName,
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) {
    return PurchaseReturn(
      id: json['id']?.toString() ?? '',
      returnId: json['return_id']?.toString() ?? '',
      returnDate: json['return_date']?.toString() ?? '',
      billId: json['bill_id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      totalRetQuantity: json['total_ret_quantity']?.toString() ?? '',
      totalRetAmt: json['total_ret_amt']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      returnBy: json['returnby']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      supplierName: json['supplier_name']?.toString() ?? '',
      materialId: json['material_id']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      returnQuantity: json['return_quantity']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      unitName: json['unit_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'return_id': returnId,
      'return_date': returnDate,
      'bill_id': billId,
      'supplier_id': supplierId,
      'total_ret_quantity': totalRetQuantity,
      'total_ret_amt': totalRetAmt,
      'company_id': companyId,
      'returnby': returnBy,
      'status': status,
      'supplier_name': supplierName,
      'material_id': materialId,
      'unit_id': unitId,
      'return_quantity': returnQuantity,
      'unit_price': unitPrice,
      'product_name': productName,
      'unit_name': unitName,
    };
  }
}