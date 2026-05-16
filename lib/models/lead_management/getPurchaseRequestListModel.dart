class GetPurchaseRequestListModel {
  final bool? status;
  final String? message;
  final List<PurchaseRequestData>? data;

  GetPurchaseRequestListModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetPurchaseRequestListModel.fromJson(Map<String, dynamic> json) {
    return GetPurchaseRequestListModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<PurchaseRequestData>.from(
              json['data'].map((x) => PurchaseRequestData.fromJson(x)))
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

class PurchaseRequestData {
  final String? id;
  final String? requestId;
  final String? requestedDate;
  final String? remarks;
  final String? requestedBy;
  final String? estimatedAmount;
  final String? requestStatus;
  final String? orderStatus;
  final String? approvedDate;
    final List<Product>? products;

  PurchaseRequestData({
    this.id,
    this.requestId,
    this.requestedDate,
    this.remarks,
    this.requestedBy,
    this.estimatedAmount,
    this.requestStatus,
    this.orderStatus,
    this.approvedDate,
       this.products,
  });

  factory PurchaseRequestData.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestData(
      id: json['id'],
      requestId: json['request_id'],
      requestedDate: json['requested_date'],
      remarks: json['remarks'],
      requestedBy: json['requested_by'],
      estimatedAmount: json['estimated_amount'],
      requestStatus: json['request_status'],
      orderStatus: json['order_status'],
      approvedDate: json['approved_date'],
       products: json['products'] != null
          ? List<Product>.from(json['products'].map((x) => Product.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'requested_date': requestedDate,
      'remarks': remarks,
      'requested_by': requestedBy,
      'estimated_amount': estimatedAmount,
      'request_status': requestStatus,
      'order_status': orderStatus,
      'approved_date': approvedDate,
       'products': products?.map((e) => e.toJson()).toList(),
    };
  }
}

class Product {
  final String? id;
  final String? materialId;
  final String? productName;
  final String? quantity;
  final String? unitAmount;
  final String? estimatedAmount;
  final String? remarks;
  final String? description;
  final String? unitName;

  Product({
    this.id,
    this.materialId,
    this.productName,
    this.quantity,
    this.unitAmount,
    this.estimatedAmount,
    this.remarks,
    this.description,
    this.unitName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      materialId: json['material_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitAmount: json['unit_amount'],
      estimatedAmount: json['estimated_amount'],
      remarks: json['remarks'],
      description: json['description'],
      unitName: json['unit_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'product_name': productName,
      'quantity': quantity,
      'unit_amount': unitAmount,
      'estimated_amount': estimatedAmount,
      'remarks': remarks,
      'description': description,
      'unit_name': unitName,
    };
  }
}
