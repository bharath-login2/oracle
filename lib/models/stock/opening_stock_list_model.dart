class OpeningStockListModel {
  bool status;
  String message;
  List<OpeningStockData> data;

  OpeningStockListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OpeningStockListModel.fromJson(Map<String, dynamic> json) {
    return OpeningStockListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<OpeningStockData>.from(
              json['data'].map((x) => OpeningStockData.fromJson(x)))
          : [],
    );
  }
}

class OpeningStockData {
  String id;
  String date;
  String locationName;
  String locationId;
  String productName;
  String unit;
  String quantity;
  String unitPrice;
  String totalAmount;
  String createdBy;
  String productId;
  String description;

  OpeningStockData({
    required this.id,
    required this.date,
    required this.locationName,
    required this.locationId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.createdBy,
    required this.productId,
    this.description = "",
  });

  factory OpeningStockData.fromJson(Map<String, dynamic> json) {
    return OpeningStockData(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '0',
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      createdBy: json['created_by']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
