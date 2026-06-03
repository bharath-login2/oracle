class GetStockRegisterListModel {
  bool status;
  String message;
  List<StockRegisterData> data;

  GetStockRegisterListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetStockRegisterListModel.fromJson(Map<String, dynamic> json) {
    return GetStockRegisterListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<StockRegisterData>.from(
              json['data'].map((x) => StockRegisterData.fromJson(x)))
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

class StockRegisterData {
  
  String materialName;
  String unit;
  String unitPrice;
  String currentQty;
  String purchasedQty;
  String consumedQty;
  String materialId;

  StockRegisterData({
    required this.materialName,
    required this.unit,
    required this.unitPrice,
    required this.currentQty,
    required this.purchasedQty,
    required this.consumedQty,
    required this.materialId,
  });

  factory StockRegisterData.fromJson(Map<String, dynamic> json) {
    return StockRegisterData(
      materialName: json['material_name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      currentQty: json['current_qty']?.toString() ?? '0',
      purchasedQty: json['purchased_qty']?.toString() ?? '0',
      consumedQty: json['consumed_qty']?.toString() ?? '0',
      materialId: json['material_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_name': materialName,
      'unit': unit,
      'unit_price': unitPrice,
      'current_qty': currentQty,
      'purchased_qty': purchasedQty,
      'consumed_qty': consumedQty,
      'material_id': materialId,
    };
  }


}