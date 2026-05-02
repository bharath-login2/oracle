class ProductHistoryRentalModel {
  bool status;
  String message;
  List<ProductHistoryData> data;

  ProductHistoryRentalModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductHistoryRentalModel.fromJson(Map<String, dynamic> json) {
    return ProductHistoryRentalModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ProductHistoryData>.from(
              json['data'].map((x) => ProductHistoryData.fromJson(x)))
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

class ProductHistoryData {
  String histId;
  String productId;
  String customerId;
  String companyId;
  String locationId;
  String actionType;
  String actionId;
  String address;
  String rentNo;
  String invoiceNo;
  String invoiceDate;
  String fromDate;
  String toDate;
  String returnDate;
  String totalDays;
  String issuedQuantity;
  String returnedQuantity;
  String addedQuantity;
  String currentStock;
  String amountPaid;
  String createdBy;
  String createdAt;
  String updatedAt;
  String customerName;
  String companyName;
  String actionUserId;
  String locationName;

  ProductHistoryData({
    required this.histId,
    required this.productId,
    required this.customerId,
    required this.companyId,
    required this.locationId,
    required this.actionType,
    required this.actionId,
    required this.address,
    required this.rentNo,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.fromDate,
    required this.toDate,
    required this.returnDate,
    required this.totalDays,
    required this.issuedQuantity,
    required this.returnedQuantity,
    required this.addedQuantity,
    required this.currentStock,
    required this.amountPaid,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.customerName,
    required this.companyName,
    required this.actionUserId,
    required this.locationName,
  });

  factory ProductHistoryData.fromJson(Map<String, dynamic> json) {
    return ProductHistoryData(
      histId: json['hist_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      actionType: json['ActionType']?.toString() ?? '',
      actionId: json['Action_Id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      rentNo: json['rent_no']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      returnDate: json['return_date']?.toString() ?? '',
      totalDays: json['total_days']?.toString() ?? '',
      issuedQuantity: json['issued_quantity']?.toString() ?? '0',
      returnedQuantity: json['returned_quantity']?.toString() ?? '0',
      addedQuantity: json['added_quantity']?.toString() ?? '',
      currentStock: json['current_stock']?.toString() ?? '',
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      actionUserId: json['action_user_id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hist_id': histId,
      'product_id': productId,
      'customer_id': customerId,
      'company_id': companyId,
      'location_id': locationId,
      'ActionType': actionType,
      'Action_Id': actionId,
      'address': address,
      'rent_no': rentNo,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'from_date': fromDate,
      'to_date': toDate,
      'return_date': returnDate,
      'total_days': totalDays,
      'issued_quantity': issuedQuantity,
      'returned_quantity': returnedQuantity,
      'added_quantity': addedQuantity,
      'current_stock': currentStock,
      'amount_paid': amountPaid,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'customer_name': customerName,
      'company_name': companyName,
      'action_user_id': actionUserId,
      'location_name': locationName,
    };
  }


}