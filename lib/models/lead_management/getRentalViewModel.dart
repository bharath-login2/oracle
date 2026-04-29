class GetRentalViewModel {
  bool? status;
  String? message;
  Data? data;

  GetRentalViewModel({
    this.status,
    this.message,
    this.data,
  });

  GetRentalViewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  RentReturn? rentReturn;
  List<dynamic>? items;

  Data({
    this.rentReturn,
    this.items,
  });

  Data.fromJson(Map<String, dynamic> json) {
    rentReturn = json['rent_return'] != null
        ? RentReturn.fromJson(json['rent_return'])
        : null;
    items = json['items'] != null ? List<dynamic>.from(json['items']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rentReturn != null) {
      data['rent_return'] = rentReturn!.toJson();
    }
    data['items'] = items;
    return data;
  }
}

class RentReturn {
  String? id;
  String? companyId;
  String? customerId;
  String? locationId;
  String? rentId;
  String? invoiceNo;
  String? returnNo;
  String? issuedDate;
  String? returnDate;
  String? advanceAmount;
  String? subTotal;
  String? discount;
  String? otherExpenses;
  String? grandTotal;
  String? createdBy;
  String? createdAt;
  String? isDeleted;
  String? updatedAt;
  String? updatedBy;
  String? deletedAt;
  String? deletedBy;
  String? customerName;
  String? locationName;

  RentReturn({
    this.id,
    this.companyId,
    this.customerId,
    this.locationId,
    this.rentId,
    this.invoiceNo,
    this.returnNo,
    this.issuedDate,
    this.returnDate,
    this.advanceAmount,
    this.subTotal,
    this.discount,
    this.otherExpenses,
    this.grandTotal,
    this.createdBy,
    this.createdAt,
    this.isDeleted,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
    this.customerName,
    this.locationName,
  });

  RentReturn.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    customerId = json['customer_id'];
    locationId = json['location_id'];
    rentId = json['rent_id'];
    invoiceNo = json['invoice_no'];
    returnNo = json['return_no'];
    issuedDate = json['issued_date'];
    returnDate = json['return_date'];
    advanceAmount = json['advance_amount'];
    subTotal = json['sub_total'];
    discount = json['discount'];
    otherExpenses = json['other_expenses'];
    grandTotal = json['grand_total'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    isDeleted = json['is_deleted'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
    customerName = json['customer_name'];
    locationName = json['location_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['company_id'] = companyId;
    data['customer_id'] = customerId;
    data['location_id'] = locationId;
    data['rent_id'] = rentId;
    data['invoice_no'] = invoiceNo;
    data['return_no'] = returnNo;
    data['issued_date'] = issuedDate;
    data['return_date'] = returnDate;
    data['advance_amount'] = advanceAmount;
    data['sub_total'] = subTotal;
    data['discount'] = discount;
    data['other_expenses'] = otherExpenses;
    data['grand_total'] = grandTotal;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['is_deleted'] = isDeleted;
    data['updated_at'] = updatedAt;
    data['updated_by'] = updatedBy;
    data['deleted_at'] = deletedAt;
    data['deleted_by'] = deletedBy;
    data['customer_name'] = customerName;
    data['location_name'] = locationName;
    return data;
  }
}