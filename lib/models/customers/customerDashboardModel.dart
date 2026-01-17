class CustomerDashboardModel {
  final bool status;
  final String message;
  final DashboardData data;

  CustomerDashboardModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerDashboardModel.fromJson(Map<String, dynamic> json) {
    return CustomerDashboardModel(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: DashboardData.fromJson(json['data'] ?? {}),
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

class DashboardData {
  final CustomerDetails customerDetails;
  final Leads leads;
  final Quotations quotations;
  final Projects projects;
  final PaymentDetails paymentDetails;
  final ProformaInvoices proformaInvoices;
  final RenewalList renewalList;
  final RentalList rentalList;

  DashboardData({
    required this.customerDetails,
    required this.leads,
    required this.quotations,
    required this.projects,
    required this.paymentDetails,
    required this.proformaInvoices,
    required this.renewalList,
    required this.rentalList,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      customerDetails: CustomerDetails.fromJson(json['customer_details'] ?? {}),
      leads: Leads.fromJson(json['leads'] ?? {}),
      quotations: Quotations.fromJson(json['quotations'] ?? {}),
      projects: Projects.fromJson(json['projects'] ?? {}),
      paymentDetails: PaymentDetails.fromJson(json['payment_details'] ?? {}),
      proformaInvoices:
          ProformaInvoices.fromJson(json['proforma_invoices'] ?? {}),
      renewalList: RenewalList.fromJson(json['renewal_list'] ?? {}),
      rentalList: RentalList.fromJson(json['rental_list'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_details': customerDetails.toJson(),
      'leads': leads.toJson(),
      'quotations': quotations.toJson(),
      'projects': projects.toJson(),
      'payment_details': paymentDetails.toJson(),
      'proforma_invoices': proformaInvoices.toJson(),
      'renewal_list': renewalList.toJson(),
      'rental_list': rentalList.toJson(),
    };
  }
}

class CustomerDetails {
  final String name;
  final String emailId;
  final String address;
  final String address2;
  final String address3;
  final String gstNum;
  final String countryCode;
  final String contactNo;
  final String stateName;
  final String districtName;
  final String createdBy;
  final String createdDate;
  final String id;
  final String leadId;
  final String postOffice;
  final String state;
  final String district;
  final String taxType;
  final String pincode;
  final String remarks;
  final String additionalFields;
  final String isDeleted;
  final String customFields;
  final String companyId;
  final String branchId;
  final String whatsappCountryCode;
  final String whatsappNumber;

  CustomerDetails({
    required this.name,
    required this.emailId,
    required this.address,
    required this.address2,
    required this.address3,
    required this.gstNum,
    required this.countryCode,
    required this.contactNo,
    required this.stateName,
    required this.districtName,
    required this.createdBy,
    required this.createdDate,
    required this.id,
    required this.leadId,
    required this.postOffice,
    required this.state,
    required this.district,
    required this.taxType,
    required this.pincode,
    required this.remarks,
    required this.additionalFields,
    required this.isDeleted,
    required this.customFields,
    required this.companyId,
    required this.branchId,
    required this.whatsappCountryCode,
    required this.whatsappNumber,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      name: json['name']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      address2: json['address2']?.toString() ?? '',
      address3: json['address3']?.toString() ?? '',
      gstNum: json['gst_num']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      contactNo: json['contact_no']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdDate: json['created_date']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      leadId: json['lead_id']?.toString() ?? '',
      postOffice: json['post_office']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      taxType: json['tax_type']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      additionalFields: json['additional_fields']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? 'N',
      customFields: json['custom_fields']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      whatsappCountryCode: json['whatsapp_country_code']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email_id': emailId,
      'address': address,
      'address2': address2,
      'address3': address3,
      'gst_num': gstNum,
      'country_code': countryCode,
      'contact_no': contactNo,
      'state_name': stateName,
      'district_name': districtName,
      'created_by': createdBy,
      'created_date': createdDate,
      'id': id,
      'lead_id': leadId,
      'post_office': postOffice,
      'state': state,
      'district': district,
      'tax_type': taxType,
      'pincode': pincode,
      'remarks': remarks,
      'additional_fields': additionalFields,
      'is_deleted': isDeleted,
      'custom_fields': customFields,
      'company_id': companyId,
      'branch_id': branchId,
      'whatsapp_country_code': whatsappCountryCode,
      'whatsapp_number': whatsappNumber,
    };
  }
}

class Leads {
  final String totalLeads;
  final String confirmedCount;

  Leads({
    required this.totalLeads,
    required this.confirmedCount,
  });

  factory Leads.fromJson(Map<String, dynamic> json) {
    return Leads(
      // Handle both String and int types
      totalLeads: _toString(json['totalLeads']),
      confirmedCount: _toString(json['confirmedCount']),
    );
  }

  static String _toString(dynamic value) {
    if (value == null) return '0';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLeads': totalLeads,
      'confirmedCount': confirmedCount,
    };
  }

  int get totalLeadsInt => int.tryParse(totalLeads) ?? 0;
  int get confirmedCountInt => int.tryParse(confirmedCount) ?? 0;
}

class Quotations {
  final String total;
  final String approved;

  Quotations({
    required this.total,
    required this.approved,
  });

  factory Quotations.fromJson(Map<String, dynamic> json) {
    return Quotations(
      total: Leads._toString(json['total']),
      approved: Leads._toString(json['approved']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'approved': approved,
    };
  }

  int get totalInt => int.tryParse(total) ?? 0;
  int get approvedInt => int.tryParse(approved) ?? 0;
}

class Projects {
  final String total;
  final String completed;

  Projects({
    required this.total,
    required this.completed,
  });

  factory Projects.fromJson(Map<String, dynamic> json) {
    return Projects(
      total: Leads._toString(json['total']),
      completed: Leads._toString(json['completed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'completed': completed,
    };
  }

  int get totalInt => int.tryParse(total) ?? 0;
  int get completedInt => int.tryParse(completed) ?? 0;
}

class PaymentDetails {
  final String totalInvoiceAmount;
  final String totalReceivedAmount;
  final String balanceAmount;
  final List<PaymentHistory> paymentHistory;

  PaymentDetails({
    required this.totalInvoiceAmount,
    required this.totalReceivedAmount,
    required this.balanceAmount,
    required this.paymentHistory,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      totalInvoiceAmount: _toCurrencyString(json['total_invoice_amount']),
      totalReceivedAmount: _toCurrencyString(json['total_received_amount']),
      balanceAmount: _toCurrencyString(json['balance_amount']),
      paymentHistory: (json['payment_history'] as List<dynamic>?)
              ?.map((item) => PaymentHistory.fromJson(item))
              .toList() ??
          [],
    );
  }

  static String _toCurrencyString(dynamic value) {
    if (value == null) return '0.00';
    if (value is String) return value;
    if (value is int) return value.toStringAsFixed(2);
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'total_invoice_amount': totalInvoiceAmount,
      'total_received_amount': totalReceivedAmount,
      'balance_amount': balanceAmount,
      'payment_history': paymentHistory.map((item) => item.toJson()).toList(),
    };
  }

  double get totalInvoiceAmountDouble =>
      double.tryParse(totalInvoiceAmount) ?? 0.0;
  double get totalReceivedAmountDouble =>
      double.tryParse(totalReceivedAmount) ?? 0.0;
  double get balanceAmountDouble => double.tryParse(balanceAmount) ?? 0.0;
}

class PaymentHistory {
  final String receiptId;
  final String recieptAmount;
  final String receiptDate;
  final String receiptNumber;
  final String invoiceId;
  final String invoiceSerial;
  final String invoiceNumber;
  final String totalPaidAmount;

  PaymentHistory({
    required this.receiptId,
    required this.recieptAmount,
    required this.receiptDate,
    required this.receiptNumber,
    required this.invoiceId,
    required this.invoiceSerial,
    required this.invoiceNumber,
    required this.totalPaidAmount,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      receiptId: Leads._toString(json['receipt_id']),
      recieptAmount: PaymentDetails._toCurrencyString(json['reciept_amount']),
      receiptDate: json['receipt_date']?.toString() ?? '',
      receiptNumber: Leads._toString(json['receipt_number']),
      invoiceId: Leads._toString(json['invoice_id']),
      invoiceSerial: json['invoice_serial']?.toString() ?? '',
      invoiceNumber: Leads._toString(json['invoice_number']),
      totalPaidAmount:
          PaymentDetails._toCurrencyString(json['total_paid_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receipt_id': receiptId,
      'reciept_amount': recieptAmount,
      'receipt_date': receiptDate,
      'receipt_number': receiptNumber,
      'invoice_id': invoiceId,
      'invoice_serial': invoiceSerial,
      'invoice_number': invoiceNumber,
      'total_paid_amount': totalPaidAmount,
    };
  }

  double get recieptAmountDouble => double.tryParse(recieptAmount) ?? 0.0;
  double get totalPaidAmountDouble => double.tryParse(totalPaidAmount) ?? 0.0;
}

class ProformaInvoices {
  final String totalProforma;
  final String totalAmount;
  final String pendingProforma;
  final String pendingAmount;

  ProformaInvoices({
    required this.totalProforma,
    required this.totalAmount,
    required this.pendingProforma,
    required this.pendingAmount,
  });

  factory ProformaInvoices.fromJson(Map<String, dynamic> json) {
    return ProformaInvoices(
      totalProforma: Leads._toString(json['total_proforma']),
      totalAmount: PaymentDetails._toCurrencyString(json['total_amount']),
      pendingProforma: Leads._toString(json['pending_proforma']),
      pendingAmount: PaymentDetails._toCurrencyString(json['pending_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_proforma': totalProforma,
      'total_amount': totalAmount,
      'pending_proforma': pendingProforma,
      'pending_amount': pendingAmount,
    };
  }

  int get totalProformaInt => int.tryParse(totalProforma) ?? 0;
  double get totalAmountDouble => double.tryParse(totalAmount) ?? 0.0;
  int get pendingProformaInt => int.tryParse(pendingProforma) ?? 0;
  double get pendingAmountDouble => double.tryParse(pendingAmount) ?? 0.0;
}

class RenewalList {
  final String totalProducts;
  final String totalRenewed;
  final String totalExpired;
  final String totalUpcoming;
  final List<UpcomingRenewal> upcomingList;

  RenewalList({
    required this.totalProducts,
    required this.totalRenewed,
    required this.totalExpired,
    required this.totalUpcoming,
    required this.upcomingList,
  });

  factory RenewalList.fromJson(Map<String, dynamic> json) {
    return RenewalList(
      totalProducts: Leads._toString(json['total_products']),
      totalRenewed: Leads._toString(json['total_renewed']),
      totalExpired: Leads._toString(json['total_expired'] ?? '0'),
      totalUpcoming: Leads._toString(json['total_upcoming'] ?? '0'),
      upcomingList: (json['upcoming_list'] as List<dynamic>?)
              ?.map((item) => UpcomingRenewal.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'total_renewed': totalRenewed,
      'total_expired': totalExpired,
      'total_upcoming': totalUpcoming,
      'upcoming_list': upcomingList.map((item) => item.toJson()).toList(),
    };
  }

  int get totalProductsInt => int.tryParse(totalProducts) ?? 0;
  int get totalRenewedInt => int.tryParse(totalRenewed) ?? 0;
  int get totalExpiredInt => int.tryParse(totalExpired) ?? 0;
  int get totalUpcomingInt => int.tryParse(totalUpcoming) ?? 0;
}

class UpcomingRenewal {
  final String productNames;
  final String endDate;
  final String daysLeft;
  final String amount;

  UpcomingRenewal({
    required this.productNames,
    required this.endDate,
    required this.daysLeft,
    required this.amount,
  });

  factory UpcomingRenewal.fromJson(Map<String, dynamic> json) {
    return UpcomingRenewal(
      productNames: json['product_names']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      daysLeft: Leads._toString(json['days_left']),
      amount: PaymentDetails._toCurrencyString(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_names': productNames,
      'end_date': endDate,
      'days_left': daysLeft,
      'amount': amount,
    };
  }

  int get daysLeftInt => int.tryParse(daysLeft) ?? 0;
  double get amountDouble => double.tryParse(amount) ?? 0.0;
}

class RentalList {
  final int issued;
  final int returned;
  final int pending;
  final List<PendingRental> pendingList;

  RentalList({
    required this.issued,
    required this.returned,
    required this.pending,
    required this.pendingList,
  });

  factory RentalList.fromJson(Map<String, dynamic> json) {
    return RentalList(
      issued: _toInt(json['issued']),
      returned: _toInt(json['returned']),
      pending: _toInt(json['pending']),
      pendingList: (json['pending_list'] as List<dynamic>?)
              ?.map((item) => PendingRental.fromJson(item))
              .toList() ??
          [],
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'issued': issued,
      'returned': returned,
      'pending': pending,
      'pending_list': pendingList.map((item) => item.toJson()).toList(),
    };
  }
}

class PendingRental {
  final String id;
  final int totalDays;
  final String toDate;
  final double grandTotal;
  final String name;

  PendingRental({
    required this.id,
    required this.totalDays,
    required this.toDate,
    required this.grandTotal,
    required this.name,
  });

  factory PendingRental.fromJson(Map<String, dynamic> json) {
    return PendingRental(
      id: Leads._toString(json['id']),
      totalDays: RentalList._toInt(json['total_days']),
      toDate: json['to_date']?.toString() ?? '',
      grandTotal: RentalList._toDouble(json['grand_total']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_days': totalDays,
      'to_date': toDate,
      'grand_total': grandTotal,
      'name': name,
    };
  }
}
