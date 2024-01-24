class ViewReceiptPdfModel {
  Data? data;
  bool? status;
  String? message;

  ViewReceiptPdfModel({this.data, this.status, this.message});

  ViewReceiptPdfModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  String? receiptId;
  String? displayRecNumber;
  String? displayInvNumber;
  String? receiptDate;
  String? collectedBy;
  String? paymentMethod;
  String? totalAmount;
  String? paidAmount;
  String? amountInWords;
  String? clientName;
  String? particulars;
  ShippingAddress? shippingAddress;
  List<CompanyDetails>? companyDetails;

  Data(
      {this.receiptId,
        this.displayRecNumber,
        this.displayInvNumber,
        this.receiptDate,
        this.collectedBy,
        this.paymentMethod,
        this.totalAmount,
        this.paidAmount,
        this.amountInWords,
        this.clientName,
        this.particulars,
        this.shippingAddress,
        this.companyDetails});

  Data.fromJson(Map<String, dynamic> json) {
    receiptId = json['receipt_id'];
    displayRecNumber = json['display_rec_number'];
    displayInvNumber = json['display_inv_number'];
    receiptDate = json['receipt_date'];
    collectedBy = json['collected_by'];
    paymentMethod = json['payment_method'];
    totalAmount = json['total_amount'];
    paidAmount = json['paid_amount'];
    amountInWords = json['amount_in_words'];
    clientName = json['client_name'];
    particulars = json['particulars'];
    shippingAddress = json['shipping_address'] != null
        ? ShippingAddress.fromJson(json['shipping_address'])
        : null;
    if (json['company_details'] != null) {
      companyDetails = <CompanyDetails>[];
      json['company_details'].forEach((v) {
        companyDetails!.add(CompanyDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['receipt_id'] = receiptId;
    data['display_rec_number'] = displayRecNumber;
    data['display_inv_number'] = displayInvNumber;
    data['receipt_date'] = receiptDate;
    data['collected_by'] = collectedBy;
    data['payment_method'] = paymentMethod;
    data['total_amount'] = totalAmount;
    data['paid_amount'] = paidAmount;
    data['amount_in_words'] = amountInWords;
    data['client_name'] = clientName;
    data['particulars'] = particulars;
    if (shippingAddress != null) {
      data['shipping_address'] = shippingAddress!.toJson();
    }
    if (companyDetails != null) {
      data['company_details'] =
          companyDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ShippingAddress {
  String? shippingName;
  String? shippingAddress;
  String? shippingCountryCode;
  String? shippingContactNo;
  String? shippingGst;
  String? shippingPincode;
  String? shippingPostOffice;

  ShippingAddress(
      {this.shippingName,
        this.shippingAddress,
        this.shippingCountryCode,
        this.shippingContactNo,
        this.shippingGst,
        this.shippingPincode,
        this.shippingPostOffice});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    shippingName = json['shipping_name'];
    shippingAddress = json['shipping_address'];
    shippingCountryCode = json['shipping_country_code'];
    shippingContactNo = json['shipping_contact_no'];
    shippingGst = json['shipping_gst'];
    shippingPincode = json['shipping_pincode'];
    shippingPostOffice = json['shipping_post_office'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shipping_name'] = shippingName;
    data['shipping_address'] = shippingAddress;
    data['shipping_country_code'] = shippingCountryCode;
    data['shipping_contact_no'] = shippingContactNo;
    data['shipping_gst'] = shippingGst;
    data['shipping_pincode'] = shippingPincode;
    data['shipping_post_office'] = shippingPostOffice;
    return data;
  }
}

class CompanyDetails {
  String? companyLogo;
  String? companyAddress;
  String? companyPincode;
  String? companyRegNo;
  String? companyEmail;
  String? companyWebsite;
  String? companyContactNo;

  CompanyDetails(
      {this.companyLogo,
        this.companyAddress,
        this.companyPincode,
        this.companyRegNo,
        this.companyEmail,
        this.companyWebsite,
        this.companyContactNo});

  CompanyDetails.fromJson(Map<String, dynamic> json) {
    companyLogo = json['company_logo'];
    companyAddress = json['company_address'];
    companyPincode = json['company_pincode'];
    companyRegNo = json['company_reg_no'];
    companyEmail = json['company_email'];
    companyWebsite = json['company_website'];
    companyContactNo = json['company_contact_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company_logo'] = companyLogo;
    data['company_address'] = companyAddress;
    data['company_pincode'] = companyPincode;
    data['company_reg_no'] = companyRegNo;
    data['company_email'] = companyEmail;
    data['company_website'] = companyWebsite;
    data['company_contact_no'] = companyContactNo;
    return data;
  }
}