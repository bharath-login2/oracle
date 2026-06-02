class GetCheckStockMaterialsResponse {
  bool? status;
  String? message;
  GetCheckStockMaterialsData? data;

  GetCheckStockMaterialsResponse({
    this.status,
    this.message,
    this.data,
  });

  GetCheckStockMaterialsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? GetCheckStockMaterialsData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GetCheckStockMaterialsData {
  String? materialId;
  String? materialName;
  String? productType;
  String? unitName;
  String? purchasePrice;
  String? rentalPrice;
  String? sellingPrice;
  String? barCode;
  String? currentStock;

  GetCheckStockMaterialsData({
    this.materialId,
    this.materialName,
    this.productType,
    this.unitName,
    this.purchasePrice,
    this.rentalPrice,
    this.sellingPrice,
    this.barCode,
    this.currentStock,
  });

  GetCheckStockMaterialsData.fromJson(Map<String, dynamic> json) {
    materialId = json['material_id']?.toString();
    materialName = json['material_name'];
    productType = json['product_type'];
    unitName = json['unit_name'];
    purchasePrice = json['purchase_price']?.toString();
    rentalPrice = json['rental_price']?.toString();
    sellingPrice = json['selling_price']?.toString();
    barCode = json['bar_code'];
    currentStock = json['current_stock']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['material_id'] = materialId;
    data['material_name'] = materialName;
    data['product_type'] = productType;
    data['unit_name'] = unitName;
    data['purchase_price'] = purchasePrice;
    data['rental_price'] = rentalPrice;
    data['selling_price'] = sellingPrice;
    data['bar_code'] = barCode;
    data['current_stock'] = currentStock;
    return data;
  }
}