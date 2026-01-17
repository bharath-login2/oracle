class MaterialListModel {
  final bool? status;
  final List<MaterialData>? data;
  final String? message;

  MaterialListModel({this.status, this.data, this.message});

  factory MaterialListModel.fromJson(Map<String, dynamic> json) {
    return MaterialListModel(
      status: json['status'],
      data: json['data'] != null
          ? List<MaterialData>.from(
              json['data'].map((x) => MaterialData.fromJson(x)),
            )
          : [],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data?.map((x) => x.toJson()).toList(),
    'message': message,
  };
}

class MaterialData {
  final String? materialId;
  final String? materialName;
  final String? productType;
  final String? unitName;
  final String? unitPrice;
  final String? currentStock;
final String? gstPercentage;
  MaterialData({
    this.materialId,
    this.materialName,
    this.productType,
    this.unitName,
    this.unitPrice,
    this.currentStock,
        this.gstPercentage,
  });

  factory MaterialData.fromJson(Map<String, dynamic> json) {
    return MaterialData(
      materialId: json['material_id'] ?? "",
      materialName: json['material_name'] ?? "",
      productType: json['product_type'] ?? "",
      unitName: json['unit_name'] ?? "",
      unitPrice: json['unit_price'] ?? "",
      currentStock: json['current_stock'] ?? "",
      gstPercentage: json['gst_percentage'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'material_id': materialId,
    'material_name': materialName,
    'product_type': productType,
    'unit_name': unitName,
    'unit_price': unitPrice,
    'current_stock': currentStock,
    'gst_percentage': gstPercentage,
  };
}
