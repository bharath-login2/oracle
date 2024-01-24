class InvoiceAddCommonDetailsModel {
  Data? data;
  bool? status;
  String? message;

  InvoiceAddCommonDetailsModel({this.data, this.status, this.message});

  InvoiceAddCommonDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? customerId;
  int? invoiceNumber;
  String? displayInvoice;
  String? totalAmountDue;
  List<PaymentStatus>? paymentStatus;
  List<PaymentMethods>? paymentMethods;
  List<CompanyDetails>? companyDetails;
  BillingAddress? billingAddress;
  ShippingAddress? shippingAddress;
  List<Products>? products;

  Data(
      {this.customerId,
        this.invoiceNumber,
        this.displayInvoice,
        this.totalAmountDue,
        this.paymentStatus,
        this.paymentMethods,
        this.companyDetails,
        this.billingAddress,
        this.shippingAddress,
        this.products});

  Data.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    invoiceNumber = json['invoice_number'];
    displayInvoice = json['display_invoice'];
    totalAmountDue = json['total_amount_due'];
    if (json['payment_status'] != null) {
      paymentStatus = <PaymentStatus>[];
      json['payment_status'].forEach((v) {
        paymentStatus!.add(PaymentStatus.fromJson(v));
      });
    }
    if (json['payment_methods'] != null) {
      paymentMethods = <PaymentMethods>[];
      json['payment_methods'].forEach((v) {
        paymentMethods!.add(PaymentMethods.fromJson(v));
      });
    }
    if (json['company_details'] != null) {
      companyDetails = <CompanyDetails>[];
      json['company_details'].forEach((v) {
        companyDetails!.add(CompanyDetails.fromJson(v));
      });
    }
    billingAddress = json['billing_address'] != null
        ? BillingAddress.fromJson(json['billing_address'])
        : null;
    shippingAddress = json['shipping_address'] != null
        ? ShippingAddress.fromJson(json['shipping_address'])
        : null;
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_id'] = customerId;
    data['invoice_number'] = invoiceNumber;
    data['display_invoice'] = displayInvoice;
    data['total_amount_due'] = totalAmountDue;
    if (paymentStatus != null) {
      data['payment_status'] =
          paymentStatus!.map((v) => v.toJson()).toList();
    }
    if (paymentMethods != null) {
      data['payment_methods'] =
          paymentMethods!.map((v) => v.toJson()).toList();
    }
    if (companyDetails != null) {
      data['company_details'] =
          companyDetails!.map((v) => v.toJson()).toList();
    }
    if (billingAddress != null) {
      data['billing_address'] = billingAddress!.toJson();
    }
    if (shippingAddress != null) {
      data['shipping_address'] = shippingAddress!.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentStatus {
  String? paymentStatus;
  String? displaySts;

  PaymentStatus({this.paymentStatus, this.displaySts});

  PaymentStatus.fromJson(Map<String, dynamic> json) {
    paymentStatus = json['payment_status'];
    displaySts = json['display_sts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['payment_status'] = paymentStatus;
    data['display_sts'] = displaySts;
    return data;
  }
}

class PaymentMethods {
  String? id;
  String? name;

  PaymentMethods({this.id, this.name});

  PaymentMethods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
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

class BillingAddress {
  String? billingName;
  String? billingAddress;
  String? billingCountryCode;
  String? billingContactNo;
  String? billingGst;
  String? billingPincode;
  String? billingPostOffice;

  BillingAddress(
      {this.billingName,
        this.billingAddress,
        this.billingCountryCode,
        this.billingContactNo,
        this.billingGst,
        this.billingPincode,
        this.billingPostOffice});

  BillingAddress.fromJson(Map<String, dynamic> json) {
    billingName = json['billing_name'];
    billingAddress = json['billing_address'];
    billingCountryCode = json['billing_country_code'];
    billingContactNo = json['billing_contact_no'];
    billingGst = json['billing_gst'];
    billingPincode = json['billing_pincode'];
    billingPostOffice = json['billing_post_office'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['billing_name'] = billingName;
    data['billing_address'] = billingAddress;
    data['billing_country_code'] = billingCountryCode;
    data['billing_contact_no'] = billingContactNo;
    data['billing_gst'] = billingGst;
    data['billing_pincode'] = billingPincode;
    data['billing_post_office'] = billingPostOffice;
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

class Products {
  String? id;
  String? productName;
  String? sellingPrice;
  String? taxPercent;
  String? taxAmount;

  Products(
      {this.id,
        this.productName,
        this.sellingPrice,
        this.taxPercent,
        this.taxAmount});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['product_name'];
    sellingPrice = json['selling_price'];
    taxPercent = json['tax_percent'];
    taxAmount = json['tax_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_name'] = productName;
    data['selling_price'] = sellingPrice;
    data['tax_percent'] = taxPercent;
    data['tax_amount'] = taxAmount;
    return data;
  }
}