class RentalReportHistoryModel {
  final bool status;
  final String message;
  final RentalReportData data;

  RentalReportHistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentalReportHistoryModel.fromJson(Map<String, dynamic> json) {
    return RentalReportHistoryModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: RentalReportData.fromJson(json['data'] ?? {}),
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

class RentalReportData {
  final RentIssue rentIssue;
  final List<RentItem> rentItems;
  final List<RentReturn> rentReturn;
  final List<Invoice> invoice;
  final PaymentSummary paymentSummary;

  RentalReportData({
    required this.rentIssue,
    required this.rentItems,
    required this.rentReturn,
    required this.invoice,
    required this.paymentSummary,
  });

  factory RentalReportData.fromJson(Map<String, dynamic> json) {
    return RentalReportData(
      rentIssue: RentIssue.fromJson(json['rent_issue'] ?? {}),
      rentItems: (json['rent_items'] as List<dynamic>?)
              ?.map((item) => RentItem.fromJson(item))
              .toList() ??
          [],
      rentReturn: (json['rent_return'] as List<dynamic>?)
              ?.map((item) => RentReturn.fromJson(item))
              .toList() ??
          [],
      invoice: (json['invoice'] as List<dynamic>?)
              ?.map((item) => Invoice.fromJson(item))
              .toList() ??
          [],
      paymentSummary: PaymentSummary.fromJson(json['payment_summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rent_issue': rentIssue.toJson(),
      'rent_items': rentItems.map((item) => item.toJson()).toList(),
      'rent_return': rentReturn.map((item) => item.toJson()).toList(),
      'invoice': invoice.map((item) => item.toJson()).toList(),
      'payment_summary': paymentSummary.toJson(),
    };
  }
}

class RentIssue {
  final String id;
  final String companyId;
  final String customerId;
  final String locationId;
  final String collectedRent;
  final String address;
  final String fromDate;
  final String toDate;
  final String totalDays;
  final String rentNo;
  final String invoiceNo;
  final String invoiceDate;
  final String advanceAmount;
  final String amountPaid;
  final String subTotal;
  final String gstTotal;
  final String discount;
  final String otherExpenses;
  final String grandTotal;
  final String createdBy;
  final String createdAt;
  final String updatedBy;
  final String updatedAt;
  final String deletedBy;
  final String deletedAt;
  final String isDeleted;
  final String customerName;
  final String locationName;
  final String collectedStaffName;

  RentIssue({
    required this.id,
    required this.companyId,
    required this.customerId,
    required this.locationId,
    required this.collectedRent,
    required this.address,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.rentNo,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.advanceAmount,
    required this.amountPaid,
    required this.subTotal,
    required this.gstTotal,
    required this.discount,
    required this.otherExpenses,
    required this.grandTotal,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.deletedBy,
    required this.deletedAt,
    required this.isDeleted,
    required this.customerName,
    required this.locationName,
    required this.collectedStaffName,
  });

  factory RentIssue.fromJson(Map<String, dynamic> json) {
    return RentIssue(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      collectedRent: json['collected_Rent']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      totalDays: json['total_days']?.toString() ?? '',
      rentNo: json['rent_no']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      advanceAmount: json['advance_amount']?.toString() ?? '',
      amountPaid: json['amount_paid']?.toString() ?? '',
      subTotal: json['sub_total']?.toString() ?? '',
      gstTotal: json['gst_total']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      otherExpenses: json['other_expenses']?.toString() ?? '',
      grandTotal: json['grand_total']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      collectedStaffName: json['collected_staff_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'customer_id': customerId,
      'location_id': locationId,
      'collected_Rent': collectedRent,
      'address': address,
      'from_date': fromDate,
      'to_date': toDate,
      'total_days': totalDays,
      'rent_no': rentNo,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'advance_amount': advanceAmount,
      'amount_paid': amountPaid,
      'sub_total': subTotal,
      'gst_total': gstTotal,
      'discount': discount,
      'other_expenses': otherExpenses,
      'grand_total': grandTotal,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'deleted_by': deletedBy,
      'deleted_at': deletedAt,
      'is_deleted': isDeleted,
      'customer_name': customerName,
      'location_name': locationName,
      'collected_staff_name': collectedStaffName,
    };
  }
}

class RentItem {
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

  RentItem({
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
  });

  factory RentItem.fromJson(Map<String, dynamic> json) {
    return RentItem(
      id: json['id']?.toString() ?? '',
      rentId: json['rent_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      days: json['days']?.toString() ?? '',
      ratePerDay: json['rate_per_day']?.toString() ?? '',
      gross: json['gross']?.toString() ?? '',
      gstPercent: json['gst_percent']?.toString() ?? '',
      gstAmount: json['gst_amount']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
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
    };
  }
}

class RentReturn {
  // Define based on your actual rent_return structure
  // Since it's empty in the sample, adding generic fields
  final Map<String, dynamic>? data;

  RentReturn({this.data});

  factory RentReturn.fromJson(Map<String, dynamic> json) {
    return RentReturn(data: json);
  }

  Map<String, dynamic> toJson() {
    return data ?? {};
  }
}

class Invoice {
  final String id;
  final String companyId;
  final String invoiceNo;
  final String rentNo;
  final String returnNo;
  final String customerId;
  final String paymentStatus;
  final String paymentMethod;
  final String totalAmount;
  final String amountPaid;
  final String balanceAmount;
  final String collectedBy;
  final String remarks;
  final String paymentDate;
  final String createdAt;
  final String createdBy;
  final String isDeleted;

  Invoice({
    required this.id,
    required this.companyId,
    required this.invoiceNo,
    required this.rentNo,
    required this.returnNo,
    required this.customerId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceAmount,
    required this.collectedBy,
    required this.remarks,
    required this.paymentDate,
    required this.createdAt,
    required this.createdBy,
    required this.isDeleted,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      rentNo: json['rent_no']?.toString() ?? '',
      returnNo: json['renturn_no']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
      amountPaid: json['amount_paid']?.toString() ?? '',
      balanceAmount: json['balance_amount']?.toString() ?? '',
      collectedBy: json['collected_by']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      paymentDate: json['payment_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'invoice_no': invoiceNo,
      'rent_no': rentNo,
      'renturn_no': returnNo,
      'customer_id': customerId,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'balance_amount': balanceAmount,
      'collected_by': collectedBy,
      'remarks': remarks,
      'payment_date': paymentDate,
      'created_at': createdAt,
      'created_by': createdBy,
      'is_deleted': isDeleted,
    };
  }
}

class PaymentSummary {
  final double totalAmount;
  final double discount;
  final double otherExpenses;
  final double billAmount;
  final double advanceAmount;
  final double cashReceived;
  final double balanceAmount;

  PaymentSummary({
    required this.totalAmount,
    required this.discount,
    required this.otherExpenses,
    required this.billAmount,
    required this.advanceAmount,
    required this.cashReceived,
    required this.balanceAmount,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      otherExpenses: (json['other_expenses'] as num?)?.toDouble() ?? 0.0,
      billAmount: (json['bill_amount'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (json['advance_amount'] as num?)?.toDouble() ?? 0.0,
      cashReceived: (json['cash_received'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_amount': totalAmount,
      'discount': discount,
      'other_expenses': otherExpenses,
      'bill_amount': billAmount,
      'advance_amount': advanceAmount,
      'cash_received': cashReceived,
      'balance_amount': balanceAmount,
    };
  }
}
