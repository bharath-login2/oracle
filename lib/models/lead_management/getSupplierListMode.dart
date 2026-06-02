class GetSupplierListModel {
  final bool status;
  final String message;
  final List<Supplier> data;

  GetSupplierListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSupplierListModel.fromJson(Map<String, dynamic> json) {
    return GetSupplierListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<Supplier>.from(json['data'].map((x) => Supplier.fromJson(x)))
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

class Supplier {
  final String supplierId;
  final String supplierName;

  Supplier({
    required this.supplierId,
    required this.supplierName,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: json['supplier_id']?.toString() ??
          json['id']?.toString() ??
          '',
      supplierName: json['supplier_name']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'supplier_name': supplierName,
    };
  }
}