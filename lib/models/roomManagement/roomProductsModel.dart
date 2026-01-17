class RoomProductListModel {
  final bool status;
  final String message;
  final List<RoomProductData> data;

  RoomProductListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RoomProductListModel.fromJson(Map<String, dynamic> json) {
    return RoomProductListModel(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => RoomProductData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class RoomProductData {
  final String id;
  final String productName;
  final String taxPercent;
  final String totalAmount;
  final String sellingPrice;
  final String description;

  RoomProductData({
    required this.id,
    required this.productName,
    required this.taxPercent,
    required this.totalAmount,
    required this.sellingPrice,
    required this.description,
  });

  factory RoomProductData.fromJson(Map<String, dynamic> json) {
    return RoomProductData(
      id: json['id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      taxPercent: json['tax_percent']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      sellingPrice: json['selling_price']?.toString() ?? '0.00',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'tax_percent': taxPercent,
      'total_amount': totalAmount,
      'selling_price': sellingPrice,
      'description': description,
    };
  }

  // Helper getters
  double get totalAmountAsDouble => double.tryParse(totalAmount) ?? 0.0;
  double get sellingPriceAsDouble => double.tryParse(sellingPrice) ?? 0.0;
  double get taxPercentAsDouble => double.tryParse(taxPercent) ?? 0.0;
  
  // Calculate tax amount
  double get taxAmount => (sellingPriceAsDouble * taxPercentAsDouble) / 100;
  
  // Formatted price
  String get formattedPrice => '₹$sellingPrice';
  
  // Formatted price with tax
  String get formattedPriceWithTax => '₹${(sellingPriceAsDouble + taxAmount).toStringAsFixed(2)}';
}