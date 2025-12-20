// request_details_model.dart
class RequestDetailsResponseModel {
  final String status;
  final String message;
  final RequestDetailsData? data;

  RequestDetailsResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory RequestDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestDetailsResponseModel(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? RequestDetailsData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class RequestDetailsData {
  final RequestDetails request;

  RequestDetailsData({
    required this.request,
  });

  factory RequestDetailsData.fromJson(Map<String, dynamic> json) {
    return RequestDetailsData(
      request: RequestDetails.fromJson(json['request']),
    );
  }

  Map<String, dynamic> toJson() => {
    'request': request.toJson(),
  };
}

class RequestDetails {
  final String id;
  final String customerName;
  final String assignedTo;
  final String createdBy;
  final String status;
  final String priority;
  final String dueDate;
  final String createdAt;
  final List<RequestProduct> products;

  RequestDetails({
    required this.id,
    required this.customerName,
    required this.assignedTo,
    required this.createdBy,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.products,
  });

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      id: json['id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      assignedTo: json['assigned_to'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => RequestProduct.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_name': customerName,
    'assigned_to': assignedTo,
    'created_by': createdBy,
    'status': status,
    'priority': priority,
    'due_date': dueDate,
    'created_at': createdAt,
    'products': products.map((e) => e.toJson()).toList(),
  };
}

class RequestProduct {
  final String productName;
  final int quantity;

  RequestProduct({
    required this.productName,
    required this.quantity,
  });

  factory RequestProduct.fromJson(Map<String, dynamic> json) {
    return RequestProduct(
      productName: json['product_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_name': productName,
    'quantity': quantity,
  };
}