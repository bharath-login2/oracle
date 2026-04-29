class ReturnDetailsRentalModel {
  final bool status;
  final String message;
  final ReturnDetailsData data;

  ReturnDetailsRentalModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReturnDetailsRentalModel.fromJson(Map<String, dynamic> json) {
    return ReturnDetailsRentalModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ReturnDetailsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ReturnDetailsData {
  final String rentIssueId;
  final String invoiceId;
  final String customerPhone;
  final String invoiceNo;
  final String rentNo;
  final String fromDate;
  final String toDate;
  final String issuedDate;
  final String collectedRent;
  final String locationName;
  final String locationId;
  final double advanceAmount;
  final double previousAmountPaid;
  final double previousGrandTotal;
  final double previousBalance;
  final List<ReturnItem> items;

  ReturnDetailsData({
    required this.rentIssueId,
    required this.invoiceId,
    required this.customerPhone,
    required this.invoiceNo,
    required this.rentNo,
    required this.fromDate,
    required this.toDate,
    required this.issuedDate,
    required this.collectedRent,
    required this.locationName,
    required this.locationId,
    required this.advanceAmount,
    required this.previousAmountPaid,
    required this.previousGrandTotal,
    required this.previousBalance,
    required this.items,
  });

  factory ReturnDetailsData.fromJson(Map<String, dynamic> json) {
    return ReturnDetailsData(
      rentIssueId: json['rent_issue_id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      rentNo: json['rent_no']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      issuedDate: json['issued_date']?.toString() ?? '',
      collectedRent: json['collected_rent']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      advanceAmount: (json['advance_amount'] as num?)?.toDouble() ?? 0.0,
      previousAmountPaid:
          (json['previous_amount_paid'] as num?)?.toDouble() ?? 0.0,
      previousGrandTotal:
          (json['previous_grand_total'] as num?)?.toDouble() ?? 0.0,
      previousBalance: (json['previous_balance'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ReturnItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rent_issue_id': rentIssueId,
      'invoice_id': invoiceId,
      'customer_phone': customerPhone,
      'invoice_no': invoiceNo,
      'rent_no': rentNo,
      'from_date': fromDate,
      'to_date': toDate,
      'issued_date': issuedDate,
      'collected_rent': collectedRent,
      'location_name': locationName,
      'location_id': locationId,
      'advance_amount': advanceAmount,
      'previous_amount_paid': previousAmountPaid,
      'previous_grand_total': previousGrandTotal,
      'previous_balance': previousBalance,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ReturnItem {
  final String id;
   final String productId;
  final String productName;
  final int qty;
  final String unitPrice;
  final int returnedQty;
  final int qtyRemaining;

  ReturnItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.returnedQty,
    required this.qtyRemaining,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      qty: json['qty'] as int? ?? 0,
      unitPrice: json['rent_price']?.toString() ?? '',
      returnedQty: json['returned_qty'] as int? ?? 0,
      qtyRemaining: json['qty_remaining'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'qty': qty,
      'rent_price': unitPrice,
      'returned_qty': returnedQty,
      'qty_remaining': qtyRemaining,
    };
  }
}
