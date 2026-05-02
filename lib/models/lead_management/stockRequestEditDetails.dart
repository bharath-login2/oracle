class StockRequestEditDetails {
  final bool status;
  final String message;
  final StockRequestData? data;

  StockRequestEditDetails({
    required this.status,
    required this.message,
    this.data,
  });

  factory StockRequestEditDetails.fromJson(Map<String, dynamic> json) {
    return StockRequestEditDetails(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? StockRequestData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class StockRequestData {
  final String id;
  final String requestId;
  final String productId;
  final String productName;
   final String remarks;
   
    final String locationId;
      final String locationName;
  final String quantity;
  final String requiredDate;
  final String requestedBy;
  final String createdAt;
  final String priority;
  final String status;
  final String remark;

  StockRequestData({
    required this.id,
    required this.requestId,
    required this.productId,
    required this.productName,
      required this.remarks,
        required this.locationId,
          required this.locationName,
    required this.quantity,
    required this.requiredDate,
    required this.requestedBy,
    required this.createdAt,
    required this.priority,
    required this.status,
    required this.remark,
  });

  factory StockRequestData.fromJson(Map<String, dynamic> json) {
    return StockRequestData(
      id: json['id']?.toString() ?? '',
      requestId: json['request_id'] ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      remarks: json['remarks'] ?? '',
      locationId: json['location_id']?.toString() ?? '',
      locationName: json['location_name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      requiredDate: json['required_date'] ?? '',
      requestedBy: json['requested_by'] ?? '',
      createdAt: json['created_at'] ?? '',
      priority: json['priority'] ?? 'Normal',
      status: json['status'] ?? 'Pending',
      remark: json['remark'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'required_date': requiredDate,
      'requested_by': requestedBy,
      'created_at': createdAt,
      'priority': priority,
      'status': status,
      'remark': remark,
    };
  }
}