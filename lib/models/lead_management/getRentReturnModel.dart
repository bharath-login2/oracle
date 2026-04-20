class GetRentReturnModel {
  bool status;
  String message;
  Data data;

  GetRentReturnModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetRentReturnModel.fromJson(Map<String, dynamic> json) {
    return GetRentReturnModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
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

class Data {
  RentReturn rentReturn;
  List<Item> items;
  List<dynamic> invoice; 

  Data({
    required this.rentReturn,
    required this.items,
    required this.invoice,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      rentReturn: RentReturn.fromJson(json['rent_return'] ?? {}),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(e))
              .toList() ??
          [],
      invoice: json['invoice'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rent_return': rentReturn.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'invoice': invoice,
    };
  }
}

class RentReturn {
  String id;
  String companyId;
  String customerId;
  String locationId;
  String rentId;
  String invoiceNo;
  String returnNo;
  String issuedDate;
  String returnDate;
  String advanceAmount;
  String subTotal;
  String discount;
  String otherExpenses;
  String grandTotal;
  String createdBy;
  String createdAt;
  String isDeleted;
  String updatedAt;
  String updatedBy;
  String deletedAt;
  String deletedBy;
  String customerName;
  String locationName;

  RentReturn({
    required this.id,
    required this.companyId,
    required this.customerId,
    required this.locationId,
    required this.rentId,
    required this.invoiceNo,
    required this.returnNo,
    required this.issuedDate,
    required this.returnDate,
    required this.advanceAmount,
    required this.subTotal,
    required this.discount,
    required this.otherExpenses,
    required this.grandTotal,
    required this.createdBy,
    required this.createdAt,
    required this.isDeleted,
    required this.updatedAt,
    required this.updatedBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.customerName,
    required this.locationName,
  });

  factory RentReturn.fromJson(Map<String, dynamic> json) {
    return RentReturn(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      rentId: json['rent_id']?.toString() ?? '',
      invoiceNo: json['invoice_no'] ?? '',
      returnNo: json['return_no'] ?? '',
      issuedDate: json['issued_date'] ?? '',
      returnDate: json['return_date'] ?? '',
      advanceAmount: json['advance_amount']?.toString() ?? '',
      subTotal: json['sub_total']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      otherExpenses: json['other_expenses']?.toString() ?? '',
      grandTotal: json['grand_total']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      isDeleted: json['is_deleted'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      deletedAt: json['deleted_at'] ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      locationName: json['location_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'customer_id': customerId,
      'location_id': locationId,
      'rent_id': rentId,
      'invoice_no': invoiceNo,
      'return_no': returnNo,
      'issued_date': issuedDate,
      'return_date': returnDate,
      'advance_amount': advanceAmount,
      'sub_total': subTotal,
      'discount': discount,
      'other_expenses': otherExpenses,
      'grand_total': grandTotal,
      'created_by': createdBy,
      'created_at': createdAt,
      'is_deleted': isDeleted,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
      'customer_name': customerName,
      'location_name': locationName,
    };
  }
}

class Item {
  String returnItemId;
  String itemId;
  String productName;
  String qtyRented;
  String returning;
  String damaged;
  String days;
  String ratePerDay;
  String total;

  Item({
    required this.returnItemId,
    required this.itemId,
    required this.productName,
    required this.qtyRented,
    required this.returning,
    required this.damaged,
    required this.days,
    required this.ratePerDay,
    required this.total,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      returnItemId: json['return_item_id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      qtyRented: json['qty_rented']?.toString() ?? '',
      returning: json['returning']?.toString() ?? '',
      damaged: json['damaged']?.toString() ?? '',
      days: json['days']?.toString() ?? '',
      ratePerDay: json['rate_per_day']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'return_item_id': returnItemId,
      'item_id': itemId,
      'product_name': productName,
      'qty_rented': qtyRented,
      'returning': returning,
      'damaged': damaged,
      'days': days,
      'rate_per_day': ratePerDay,
      'total': total,
    };
  }
}