class GetMaterialForStockConsumptionModel {
  final bool status;
  final String message;
  final List<ConsumptionMaterialData> data;

  GetMaterialForStockConsumptionModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetMaterialForStockConsumptionModel.fromJson(Map<String, dynamic> json) {
    return GetMaterialForStockConsumptionModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((e) => ConsumptionMaterialData.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ConsumptionMaterialData {
  final String id;
  final String productName;
  final String unitId;
  final String unitPrice;
  final String currentStock;
  final String unitName;

  ConsumptionMaterialData({
    required this.id,
    required this.productName,
    required this.unitId,
    required this.unitPrice,
    required this.currentStock,
    required this.unitName,
  });

  factory ConsumptionMaterialData.fromJson(Map<String, dynamic> json) {
    return ConsumptionMaterialData(
      id: json['id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      currentStock: json['current_stock']?.toString() ?? '',
      unitName: json['unit_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'unit_id': unitId,
      'unit_price': unitPrice,
      'current_stock': currentStock,
      'unit_name': unitName,
    };
  }
}