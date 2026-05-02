class GetOpeningModel {
  bool status;
  String message;
  List<OpeningStockData> data;

  GetOpeningModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetOpeningModel.fromJson(Map<String, dynamic> json) {
    return GetOpeningModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<OpeningStockData>.from(
              json['data'].map((x) => OpeningStockData.fromJson(x)))
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

class OpeningStockData {
  String stockOpeningItemId;
  String date;
  String location;
  String materialName;
  String unit;
  String quantity;
  String unitPrice;
  String totalAmount;
  String staffName;

  OpeningStockData({
    required this.stockOpeningItemId,
    required this.date,
    required this.location,
    required this.materialName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.staffName,
  });

  factory OpeningStockData.fromJson(Map<String, dynamic> json) {
    return OpeningStockData(
      stockOpeningItemId: json['stock_opening_item_id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      materialName: json['material_name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '0',
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0',
      staffName: json['staff_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_opening_item_id': stockOpeningItemId,
      'date': date,
      'location': location,
      'material_name': materialName,
      'unit': unit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'staff_name': staffName,
    };
  }


}