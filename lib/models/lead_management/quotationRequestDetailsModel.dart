class QuoRequestDetailsResponse {
  final String status;
  final String message;
  final QuoRequestData data;

  QuoRequestDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QuoRequestDetailsResponse.fromJson(Map<String, dynamic> json) {
    return QuoRequestDetailsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: QuoRequestData.fromJson(json['data'] ?? {}),
    );
  }
}

class QuoRequestData {
  final QuoRequest request;

  QuoRequestData({required this.request});

  factory QuoRequestData.fromJson(Map<String, dynamic> json) {
    return QuoRequestData(
      request: QuoRequest.fromJson(json['request'] ?? {}),
    );
  }
}

class QuoRequest {
  final String id;
  final String customerName;
  final String assignedTo;
  final String createdBy;
  final String status;
  final String priority;
    final String remarks;
  final String dueDate;
  final String createdAt;
  final List<Product> products;

  QuoRequest({
    required this.id,
    required this.customerName,
    required this.assignedTo,
    required this.createdBy,
    required this.status,
    required this.priority,
     required this.remarks,
    required this.dueDate,
    required this.createdAt,
    required this.products,
  });

  factory QuoRequest.fromJson(Map<String, dynamic> json) {
    return QuoRequest(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      createdBy: json['created_by'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
       remarks: json['remarks'] ?? '',
      dueDate: json['due_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      products: (json['products'] as List? ?? [])
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

class Product {
    final String productId;
  final String productName;
  final int quantity;

  Product({
      required this.productId,
    required this.productName,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
       productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
    );
  }
}



