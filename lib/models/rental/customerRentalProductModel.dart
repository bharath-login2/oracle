// customer_rental_product_list_model.dart

class CustomerRentalProductListModel {
  final bool status;
  final CustomerRentalData data;

  CustomerRentalProductListModel({
    required this.status,
    required this.data,
  });

  factory CustomerRentalProductListModel.fromJson(Map<String, dynamic> json) {
    return CustomerRentalProductListModel(
      status: json['status'] as bool,
      data: CustomerRentalData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class CustomerRentalData {
  final String customerPhone;
  final String invoiceNo;
  final String fromDate;
  final String toDate;
  final String locations;
  final String locationId;
  final String issuedDate;
  final String advanceAmount;
  final List<RentalItem> items;

  CustomerRentalData({
    required this.customerPhone,
    required this.invoiceNo,
    required this.fromDate,
    required this.toDate,
    required this.locations,
    required this.locationId,
    required this.issuedDate,
    required this.advanceAmount,
    required this.items,
  });

  factory CustomerRentalData.fromJson(Map<String, dynamic> json) {
    return CustomerRentalData(
      customerPhone: json['customer_phone'] as String,
      invoiceNo: json['invoice_no'] as String,
      fromDate: json['from_date'] as String,
      toDate: json['to_date'] as String,
      locations: json['locations'] as String,
      locationId: json['location_id'] as String,
      issuedDate: json['issued_date'] as String,
      advanceAmount: json['advance_amount'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => RentalItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_phone': customerPhone,
      'invoice_no': invoiceNo,
      'from_date': fromDate,
      'to_date': toDate,
      'locations': locations,
      'location_id': locationId,
      'issued_date': issuedDate,
      'advance_amount': advanceAmount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class RentalItem {
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
  final String productName;
  final String returnedQty;
  final int qtyRemaining;

  RentalItem({
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
    required this.productName,
    required this.returnedQty,
    required this.qtyRemaining,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      id: json['id'] as String,
      rentId: json['rent_id'] as String,
      productId: json['product_id'] as String,
      qty: json['qty'] as String,
      unitPrice: json['unit_price'] as String,
      days: json['days'] as String,
      ratePerDay: json['rate_per_day'] as String,
      gross: json['gross'] as String,
      gstPercent: json['gst_percent'] as String,
      gstAmount: json['gst_amount'] as String,
      total: json['total'] as String,
      createdAt: json['created_at'] as String,
      companyId: json['company_id'] as String,
      productName: json['product_name'] as String,
      returnedQty: json['returned_qty'] as String,
      qtyRemaining: (json['qty_remaining'] as num).toInt(),
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
      'product_name': productName,
      'returned_qty': returnedQty,
      'qty_remaining': qtyRemaining,
    };
  }

}