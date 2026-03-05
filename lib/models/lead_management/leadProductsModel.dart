class LeadProductSectionModel {
  final List<LeadProduct>? data;
  final bool? status;
  final String? message;

  LeadProductSectionModel({
    this.data,
    this.status,
    this.message,
  });

  factory LeadProductSectionModel.fromJson(Map<String, dynamic> json) {
    return LeadProductSectionModel(
      data: json['data'] != null
          ? List<LeadProduct>.from(
              json['data'].map((x) => LeadProduct.fromJson(x)))
          : null,
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((x) => x.toJson()).toList(),
      'status': status,
      'message': message,
    };
  }
}

class LeadProduct {
  final String? id;
  final String? productName;
  final String? sellingPrice;
  final String? taxPercent;
  final String? totalAmount;

  LeadProduct({
    this.id,
    this.productName,
    this.sellingPrice,
    this.taxPercent,
    this.totalAmount,
  });

  factory LeadProduct.fromJson(Map<String, dynamic> json) {
    return LeadProduct(
      id: json['id']?.toString(),
      productName: json['product_name'],
      sellingPrice: json['selling_price'],
      taxPercent: json['tax_percent'],
      totalAmount: json['total_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'selling_price': sellingPrice,
      'tax_percent': taxPercent,
      'total_amount': totalAmount,
    };
  }
}
