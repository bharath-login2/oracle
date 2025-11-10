class EditInvoiceDetailsModelGST {
  Data? data;
  bool? status;
  String? message;

  EditInvoiceDetailsModelGST({this.data, this.status, this.message});

  EditInvoiceDetailsModelGST.fromJson(Map<String, dynamic> json) {
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
  String? invRowId;
  String? receiptId;
  String? displayInvoice;
  String? invoiceDate;
  String? invoicePaymentStatus;
  String? subTotal;
  String? estimatedTax;
  String? discountAmount;
  String? shippingAmount;
  String? totalInvoiceAmount;
  String? remarks;
  String? receiptCount;
  List<ProductDetails>? productDetails;
  String? totalAmountDue;
  BillingAddress? billingAddress;
  ShippingAddress? shippingAddress;
  List<CompanyDetails>? companyDetails;

  Data(
      {this.customerId,
        this.invRowId,
        this.receiptId,
        this.displayInvoice,
        this.invoiceDate,
        this.invoicePaymentStatus,
        this.subTotal,
        this.estimatedTax,
        this.discountAmount,
        this.shippingAmount,
        this.totalInvoiceAmount,
        this.remarks,
        this.receiptCount,
        this.productDetails,
        this.totalAmountDue,
        this.billingAddress,
        this.shippingAddress,
        this.companyDetails});

  Data.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    invRowId = json['inv_row_id'];
    receiptId = json['receipt_id'];
    displayInvoice = json['display_invoice'];
    invoiceDate = json['invoice_date'];
    invoicePaymentStatus = json['invoice_payment_status']??"";
    subTotal = json['sub_total'];
    estimatedTax = json['estimated_tax'];
    discountAmount = json['discount_amount'];
    shippingAmount = json['shipping_amount'];
    totalInvoiceAmount = json['total_invoice_amount'];
    remarks = json['remarks'];
    receiptCount = json['receipt_count'];
    if (json['product_details'] != null) {
      productDetails = <ProductDetails>[];
      json['product_details'].forEach((v) {
        productDetails!.add(ProductDetails.fromJson(v));
      });
    }
    totalAmountDue = json['total_amount_due'];
    billingAddress = json['billing_address'] != null
        ? BillingAddress.fromJson(json['billing_address'])
        : null;
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
    data['customer_id'] = customerId;
    data['inv_row_id'] = invRowId;
    data['receipt_id'] = receiptId;
    data['display_invoice'] = displayInvoice;
    data['invoice_date'] = invoiceDate;
    data['invoice_payment_status'] = invoicePaymentStatus;
    data['sub_total'] = subTotal;
    data['estimated_tax'] = estimatedTax;
    data['discount_amount'] = discountAmount;
    data['shipping_amount'] = shippingAmount;
    data['total_invoice_amount'] = totalInvoiceAmount;
    data['remarks'] = remarks;
    data['receipt_count'] = receiptCount;
    if (productDetails != null) {
      data['product_details'] =
          productDetails!.map((v) => v.toJson()).toList();
    }
    data['total_amount_due'] = totalAmountDue;
    if (billingAddress != null) {
      data['billing_address'] = billingAddress!.toJson();
    }
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

class ProductDetails {
  String? rowId;
  String? productId;
  String? productName;
  String? productDescription;
  String? rate;
  String? qty;
  String? taxPercentage;
  String? taxAmount;
  String? amount;

  ProductDetails(
      {this.rowId,
        this.productId,
        this.productName,
        this.productDescription,
        this.rate,
        this.qty,
        this.taxPercentage,
        this.taxAmount,
        this.amount});

  ProductDetails.fromJson(Map<String, dynamic> json) {
    rowId = json['row_id'];
    productId = json['product_id'];
    productName = json['product_name'];
    productDescription = json['product_description'];
    rate = json['rate'];
    qty = json['qty'];
    taxPercentage = json['tax_percentage'];
    taxAmount = json['tax_amount'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['row_id'] = rowId;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_description'] = productDescription;
    data['rate'] = rate;
    data['qty'] = qty;
    data['tax_percentage'] = taxPercentage;
    data['tax_amount'] = taxAmount;
    data['amount'] = amount;
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