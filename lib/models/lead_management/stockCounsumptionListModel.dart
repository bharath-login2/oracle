class StockConsumptionListModel {
  final bool status;
  final String message;
  final List<ConsumptionData> data;

  StockConsumptionListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StockConsumptionListModel.fromJson(Map<String, dynamic> json) {
    return StockConsumptionListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((e) => ConsumptionData.fromJson(e)).toList()
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

class ConsumptionData {
  final String id;
  final String date;
  final String materialName;
  final String unit;
  final String quantity;
  final String unitPrice;
  final String totalAmount;

  ConsumptionData({
    required this.id,
    required this.date,
    required this.materialName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  factory ConsumptionData.fromJson(Map<String, dynamic> json) {
    return ConsumptionData(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      materialName: json['material_name'] ?? '',
      unit: json['unit'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'material_name': materialName,
      'unit': unit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
    };
  }
}