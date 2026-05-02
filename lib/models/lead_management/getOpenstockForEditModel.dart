class GetOpenstockForEditModel {
  bool? status;
  String? message;
  Data? data;

  GetOpenstockForEditModel({this.status, this.message, this.data});

  GetOpenstockForEditModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? stockOpeningItemId;
  String? materialId;
  String? materialName;
  String? unitId;
  String? unit;
  String? unitPrice;
  String? quantity;

  Data({
    this.stockOpeningItemId,
    this.materialId,
    this.materialName,
    this.unitId,
    this.unit,
    this.unitPrice,
    this.quantity,
  });

  Data.fromJson(Map<String, dynamic> json) {
    stockOpeningItemId = json['stock_opening_item_id'];
    materialId = json['material_id'];
    materialName = json['material_name'];
    unitId = json['unit_id'];
    unit = json['unit'];
    unitPrice = json['unit_price'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stock_opening_item_id'] = stockOpeningItemId;
    data['material_id'] = materialId;
    data['material_name'] = materialName;
    data['unit_id'] = unitId;
    data['unit'] = unit;
    data['unit_price'] = unitPrice;
    data['quantity'] = quantity;
    return data;
  }
}