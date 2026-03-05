class GetRentalIssueDetailsModel {
  final bool status;
  final String message;
  final RentalIssueData? data;

  GetRentalIssueDetailsModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory GetRentalIssueDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetRentalIssueDetailsModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? RentalIssueData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'GetRentalIssueDetailsModel(status: $status, message: $message, data: $data)';
  }
}

class RentalIssueData {
  final String customerPhone;
  final String invoiceNo;
  final String fromDate;
  final String toDate;
  final String locationName;
  final String locationId;
  final String issuedDate;
  final String advanceAmount;
  final String amountPaid;
  final String grandTotal;
  final String rentIssueId;
  final String invoiceId;
  final List<RentalIssueItem> items;

  RentalIssueData({
    required this.customerPhone,
    required this.invoiceNo,
    required this.fromDate,
    required this.toDate,
    required this.locationName,
    required this.locationId,
    required this.issuedDate,
    required this.advanceAmount,
    required this.amountPaid,
    required this.grandTotal,
    required this.rentIssueId,
    required this.invoiceId,
    required this.items,
  });

  factory RentalIssueData.fromJson(Map<String, dynamic> json) {
    return RentalIssueData(
      customerPhone: json['customer_phone']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      issuedDate: json['issued_date']?.toString() ?? '',
      advanceAmount: json['advance_amount']?.toString() ?? '0.00',
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      grandTotal: json['grand_total']?.toString() ?? '0.00',
      rentIssueId: json['rent_issue_id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => RentalIssueItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_phone': customerPhone,
      'invoice_no': invoiceNo,
      'from_date': fromDate,
      'to_date': toDate,
      'location_name': locationName,
      'location_id': locationId,
      'issued_date': issuedDate,
      'advance_amount': advanceAmount,
      'amount_paid': amountPaid,
      'grand_total': grandTotal,
      'rent_issue_id': rentIssueId,
      'invoice_id': invoiceId,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  // Helper getters for numeric values
  double get advanceAmountValue => double.tryParse(advanceAmount) ?? 0.0;
  double get amountPaidValue => double.tryParse(amountPaid) ?? 0.0;
  double get grandTotalValue => double.tryParse(grandTotal) ?? 0.0;
  double get balanceAmount => grandTotalValue - amountPaidValue;

  // Formatted getters
  String get formattedAdvanceAmount =>
      '₹${double.tryParse(advanceAmount)?.toStringAsFixed(2) ?? '0.00'}';
  String get formattedAmountPaid =>
      '₹${double.tryParse(amountPaid)?.toStringAsFixed(2) ?? '0.00'}';
  String get formattedGrandTotal =>
      '₹${double.tryParse(grandTotal)?.toStringAsFixed(2) ?? '0.00'}';
  String get formattedBalanceAmount => '₹${balanceAmount.toStringAsFixed(2)}';

  @override
  String toString() {
    return 'RentalIssueData(invoiceNo: $invoiceNo, customerPhone: $customerPhone, itemsCount: ${items.length})';
  }
}

class RentalIssueItem {
  final String id;
  final String rentId;
  final String productId;
  final String qty;
  final String unitPrice;
  final String days;
  final String ratePerDay;
  final String gross;
  final String gstPercent;
  final String gstAmount;
  final String total;
  final String createdAt;
  final String companyId;
  final String locationId;
  final String deletedAt;
  final String deletedBy;
  final String isDeleted;
  final String productName;
  final String totalReturned;
  final String totalDamaged;
  final String returnedQty;
  final int qtyRemaining;

  RentalIssueItem({
    required this.id,
    required this.rentId,
    required this.productId,
    required this.qty,
    required this.unitPrice,
    required this.days,
    required this.ratePerDay,
    required this.gross,
    required this.gstPercent,
    required this.gstAmount,
    required this.total,
    required this.createdAt,
    required this.companyId,
    required this.locationId,
    required this.deletedAt,
    required this.deletedBy,
    required this.isDeleted,
    required this.productName,
    required this.totalReturned,
    required this.totalDamaged,
    required this.returnedQty,
    required this.qtyRemaining,
  });

  factory RentalIssueItem.fromJson(Map<String, dynamic> json) {
    return RentalIssueItem(
      id: json['id']?.toString() ?? '',
      rentId: json['rent_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '0',
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      days: json['days']?.toString() ?? '0',
      ratePerDay: json['rate_per_day']?.toString() ?? '0.00',
      gross: json['gross']?.toString() ?? '0.00',
      gstPercent: json['gst_percent']?.toString() ?? '0',
      gstAmount: json['gst_amount']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
      createdAt: json['created_at']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? 'N',
      productName: json['product_name']?.toString() ?? '',
      totalReturned: json['total_returned']?.toString() ?? '0',
      totalDamaged: json['total_damaged']?.toString() ?? '0',
      returnedQty: json['returned_qty']?.toString() ?? '0',
      qtyRemaining: json['qty_remaining'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rent_id': rentId,
      'product_id': productId,
      'qty': qty,
      'unit_price': unitPrice,
      'days': days,
      'rate_per_day': ratePerDay,
      'gross': gross,
      'gst_percent': gstPercent,
      'gst_amount': gstAmount,
      'total': total,
      'created_at': createdAt,
      'company_id': companyId,
      'location_id': locationId,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
      'is_deleted': isDeleted,
      'product_name': productName,
      'total_returned': totalReturned,
      'total_damaged': totalDamaged,
      'returned_qty': returnedQty,
      'qty_remaining': qtyRemaining,
    };
  }
}
