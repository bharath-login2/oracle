class BookingDetailsResponse {
  final bool status;
  final String message;
  final BookingData data;

  BookingDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BookingDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BookingDetailsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: BookingData.fromJson(json['data'] ?? {}),
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

class BookingData {
  final BookingDetail bookingDetails;
  final List<ProductDetail> productDetails;
  final List<BookingRoom> bookingRoomsList;

  BookingData({
    required this.bookingDetails,
    required this.productDetails,
    required this.bookingRoomsList,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      bookingDetails: BookingDetail.fromJson(json['booking_details'] ?? {}),
      productDetails: (json['product_details'] as List<dynamic>?)
          ?.map((item) => ProductDetail.fromJson(item))
          .toList() ??
          [],
      bookingRoomsList: (json['booking_rooms_list'] as List<dynamic>?)
          ?.map((item) => BookingRoom.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_details': bookingDetails.toJson(),
      'product_details': productDetails.map((e) => e.toJson()).toList(),
      'booking_rooms_list': bookingRoomsList.map((e) => e.toJson()).toList(),
    };
  }
}

class BookingDetail {
  final String id;
  final String statusId;
  final String bookingDate;
  final String checkInDate;
  final String invoiceNumber;
  final String invoiceDate;
  final String totalTax;
  final String discount;
  final String additionalCharge;
  final String paymentStatus;
  final String totalAmount;
  final String totalAmountPaid;
  final String amountPaidCustomer;
  final String paymentMethodId;
  final String subTotal;
  final String name;
  final String emailId;
  final String nationality;
  final String contactNo;
  final String whatsappNumber;
  final String address;
  final String pincode;
  final String postOffice;
  final String stateId;
  final String districtId;
  final String customerType;
  final String customerId;
  final String discountAmount;
  final String masterId;
  final String bookingType;
  final String platformType;
  final String stayType;
  final String collectedBy;
  final String lastPaymentMethod;

  BookingDetail({
    required this.id,
    required this.statusId,
    required this.bookingDate,
    required this.checkInDate,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.totalTax,
    required this.discount,
    required this.additionalCharge,
    required this.paymentStatus,
    required this.totalAmount,
    required this.totalAmountPaid,
    required this.amountPaidCustomer,
    required this.paymentMethodId,
    required this.subTotal,
    required this.name,
    required this.emailId,
    required this.nationality,
    required this.contactNo,
    required this.whatsappNumber,
    required this.address,
    required this.pincode,
    required this.postOffice,
    required this.stateId,
    required this.districtId,
    required this.customerType,
    required this.customerId,
    required this.discountAmount,
    required this.masterId,
    required this.bookingType,
    required this.platformType,
    required this.stayType,
    required this.collectedBy,
    required this.lastPaymentMethod,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id']?.toString() ?? '',
      statusId: json['status_id']?.toString() ?? '',
      bookingDate: json['booking_date']?.toString() ?? '',
      checkInDate: json['check_in_date']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      totalTax: json['total_tax']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      additionalCharge: json['additional_charge']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
      totalAmountPaid: json['total_amount_paid']?.toString() ?? '',
      amountPaidCustomer: json['amount_paid_customer']?.toString() ?? '',
      paymentMethodId: json['payment_method_id']?.toString() ?? '',
      subTotal: json['sub_total']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      nationality: json['nationality']?.toString() ?? '',
      contactNo: json['contact_no']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      postOffice: json['post_office']?.toString() ?? '',
      stateId: json['state_id']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
      customerType: json['customer_type']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      discountAmount: json['discount_amount']?.toString() ?? '',
      masterId: json['master_id']?.toString() ?? '',
      bookingType: json['booking_type']?.toString() ?? '',
      platformType: json['platform_type']?.toString() ?? '',
      stayType: json['stay_type']?.toString() ?? '',
      collectedBy: json['collected_by']?.toString() ?? '',
      lastPaymentMethod: json['last_payment_method']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_id': statusId,
      'booking_date': bookingDate,
      'check_in_date': checkInDate,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'total_tax': totalTax,
      'discount': discount,
      'additional_charge': additionalCharge,
      'payment_status': paymentStatus,
      'total_amount': totalAmount,
      'total_amount_paid': totalAmountPaid,
      'amount_paid_customer': amountPaidCustomer,
      'payment_method_id': paymentMethodId,
      'sub_total': subTotal,
      'name': name,
      'email_id': emailId,
      'nationality': nationality,
      'contact_no': contactNo,
      'whatsapp_number': whatsappNumber,
      'address': address,
      'pincode': pincode,
      'post_office': postOffice,
      'state_id': stateId,
      'district_id': districtId,
      'customer_type': customerType,
      'customer_id': customerId,
      'discount_amount': discountAmount,
      'master_id': masterId,
      'booking_type': bookingType,
      'platform_type': platformType,
      'stay_type': stayType,
      'collected_by': collectedBy,
      'last_payment_method': lastPaymentMethod,
    };
  }
}

class ProductDetail {
  final String id;
  final String bookingId;
  final String productId;
  final String rate;
  final String quantity;
  final String tax;
  final String amount;
  final String isDeleted;
  final String companyId;
  final String branchId;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  final String deletedAt;
  final String deletedBy;
  final String productName;

  ProductDetail({
    required this.id,
    required this.bookingId,
    required this.productId,
    required this.rate,
    required this.quantity,
    required this.tax,
    required this.amount,
    required this.isDeleted,
    required this.companyId,
    required this.branchId,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.productName,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      rate: json['rate']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      tax: json['tax']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'product_id': productId,
      'rate': rate,
      'quantity': quantity,
      'tax': tax,
      'amount': amount,
      'is_deleted': isDeleted,
      'company_id': companyId,
      'branch_id': branchId,
      'created_at': createdAt,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
      'product_name': productName,
    };
  }
}

class BookingRoom {
  final String id;
  final String roomNumberId;
  final String amount;
  final String days;
  final String hour;
  final String adult;
  final String children;
  final String checkOutDate;
  final String taxPercent;
  final String roomTypeId;
  final String totalAmount;

  BookingRoom({
    required this.id,
    required this.roomNumberId,
    required this.amount,
    required this.days,
    required this.hour,
    required this.adult,
    required this.children,
    required this.checkOutDate,
    required this.taxPercent,
    required this.roomTypeId,
    required this.totalAmount,
  });

  factory BookingRoom.fromJson(Map<String, dynamic> json) {
    return BookingRoom(
      id: json['id']?.toString() ?? '',
      roomNumberId: json['room_number_id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      days: json['days']?.toString() ?? '',
      hour: json['hour']?.toString() ?? '',
      adult: json['adult']?.toString() ?? '',
      children: json['children']?.toString() ?? '',
      checkOutDate: json['check_out_date']?.toString() ?? '',
      taxPercent: json['tax_percent']?.toString() ?? '',
      roomTypeId: json['room_type_id']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number_id': roomNumberId,
      'amount': amount,
      'days': days,
      'hour': hour,
      'adult': adult,
      'children': children,
      'check_out_date': checkOutDate,
      'tax_percent': taxPercent,
      'room_type_id': roomTypeId,
      'total_amount': totalAmount,
    };
  }
}