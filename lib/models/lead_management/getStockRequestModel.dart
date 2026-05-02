class GetStockRequestModel {
  bool? status;
  String? message;
  List<StockRequestData>? data;

  GetStockRequestModel({this.status, this.message, this.data});

  GetStockRequestModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <StockRequestData>[];
      json['data'].forEach((v) {
        data!.add(StockRequestData.fromJson(v));
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

class StockRequestData {
  String? requestId;
  String? requestedBy;
  String? productName;
  String? quantity;
  String? requiredDate;
  String? id;

  StockRequestData({
    this.requestId,
    this.requestedBy,
    this.productName,
    this.quantity,
    this.requiredDate,
    this.id,
  });

  StockRequestData.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id'];
    requestedBy = json['requested_by'];
    productName = json['product_name'];
    quantity = json['quantity'];
    requiredDate = json['required_date'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_id'] = requestId;
    data['requested_by'] = requestedBy;
    data['product_name'] = productName;
    data['quantity'] = quantity;
    data['required_date'] = requiredDate;
    data['id'] = id;
    return data;
  }
}