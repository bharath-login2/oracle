// request_response_model.dart
class RequestResponseModel {
  final String status;
  final String message;
  final RequestData? data;

  RequestResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory RequestResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestResponseModel(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? RequestData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class RequestData {
  final CustomerData customerData;
  final List<ProductDetail> productDetails;

  RequestData({
    required this.customerData,
    required this.productDetails,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      customerData: CustomerData.fromJson(json['customer_data']),
      productDetails: (json['product_details'] as List)
          .map((item) => ProductDetail.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'customer_data': customerData.toJson(),
    'product_details': productDetails.map((e) => e.toJson()).toList(),
  };
}

class CustomerData {
  final String customerName;
  final String address;
  final String district;
  final String state;

  CustomerData({
    required this.customerName,
    required this.address,
    required this.district,
    required this.state,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      customerName: json['customer_name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'customer_name': customerName,
    'address': address,
    'district': district,
    'state': state,
  };
}

class ProductDetail {
  final String productname;
  final int quantity;
  final double unitPrice;
  final String unit;
  final double gst;
  final String total;
  final String subtotal;

  ProductDetail({
    required this.productname,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    required this.gst,
    required this.total,
    required this.subtotal,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productname: json['productname'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      total: json['total'] as String? ?? '0.00',
      subtotal: json['subtotal'] as String? ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() => {
    'productname': productname,
    'quantity': quantity,
    'unit_price': unitPrice,
    'unit': unit,
    'gst': gst,
    'total': total,
    'subtotal': subtotal,
  };
}