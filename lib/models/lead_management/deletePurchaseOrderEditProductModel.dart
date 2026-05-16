class DeletePurchaseOrderEditProductModel {
  final bool? status;
  final String? message;
  final DeletePurchaseOrderEditProductData? data;

  DeletePurchaseOrderEditProductModel({
    this.status,
    this.message,
    this.data,
  });

  factory DeletePurchaseOrderEditProductModel.fromJson(Map<String, dynamic> json) {
    return DeletePurchaseOrderEditProductModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? DeletePurchaseOrderEditProductData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class DeletePurchaseOrderEditProductData {
  final String? requestId;
  final String? totalEstimatedAmount;

  DeletePurchaseOrderEditProductData({
    this.requestId,
    this.totalEstimatedAmount,
  });

  factory DeletePurchaseOrderEditProductData.fromJson(Map<String, dynamic> json) {
    return DeletePurchaseOrderEditProductData(
      requestId: json['request_id'],
      totalEstimatedAmount: json['total_estimated_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'total_estimated_amount': totalEstimatedAmount,
    };
  }
}