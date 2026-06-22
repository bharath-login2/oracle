class GetStockRequestModel {
  bool? status;
  String? message;
  List<StockRequestData>? data;

  GetStockRequestModel({
    this.status,
    this.message,
    this.data,
  });

  GetStockRequestModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    if (json['data'] != null) {
      data = <StockRequestData>[];
      for (var v in json['data']) {
        data!.add(StockRequestData.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};

    dataMap['status'] = status;
    dataMap['message'] = message;

    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }

    return dataMap;
  }
}

class StockRequestData {
  String? requestId;
  String? requestedBy;
  String? requiredDate;
  String? requestedDate;
  String? approvedAt;
  String? approvedBy;
  String? priority;
  String? id;
  String? status;

  List<StockRequestProduct>? products;

  StockRequestData({
    this.requestId,
    this.requestedBy,
    this.requiredDate,
    this.requestedDate,
    this.approvedAt,
    this.approvedBy,
    this.priority,
    this.id,
    this.status,
    this.products,
  });

  StockRequestData.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id']?.toString();
    requestedBy = json['requested_by']?.toString();
    requiredDate = json['required_date']?.toString();
    requestedDate = json['requested_date']?.toString();
    approvedAt = json['approved_at']?.toString();
    approvedBy = json['approved_by']?.toString();
    priority = json['priority']?.toString();
    id = json['id']?.toString();
    status = json['status']?.toString();

    if (json['products'] != null &&
        json['products'] is List) {
      products = <StockRequestProduct>[];

      for (var v in json['products']) {
        products!.add(
          StockRequestProduct.fromJson(v),
        );
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};

    dataMap['request_id'] = requestId;
    dataMap['requested_by'] = requestedBy;
    dataMap['required_date'] = requiredDate;
    dataMap['requested_date'] = requestedDate;
    dataMap['approved_at'] = approvedAt;
    dataMap['approved_by'] = approvedBy;
    dataMap['priority'] = priority;
    dataMap['id'] = id;
    dataMap['status'] = status;
    if (products != null) {
      dataMap['products'] =
          products!.map((v) => v.toJson()).toList();
    }

    return dataMap;
  }
}

class StockRequestProduct {
  String? productId;
  String? productName;
  String? quantity;
  String? remark;

  StockRequestProduct({
    this.productId,
    this.productName,
    this.quantity,
    this.remark,
  });

  StockRequestProduct.fromJson(
      Map<String, dynamic> json) {
    productId = json['product_id']?.toString();
    productName = json['product_name']?.toString();
    quantity = json['quantity']?.toString();
    remark = json['remarks']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'remark': remark,
    };
  }
}