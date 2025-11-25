// To parse this JSON data, do
//
//     final invoiceAddCommonDetailsModel = invoiceAddCommonDetailsModelFromJson(jsonString);

import 'dart:convert';

InvoiceAddCommonDetailsModelTemp invoiceAddCommonDetailsModelFromJson(
        String str) =>
    InvoiceAddCommonDetailsModelTemp.fromJson(json.decode(str));

String invoiceAddCommonDetailsModelToJson(
        InvoiceAddCommonDetailsModelTemp data) =>
    json.encode(data.toJson());

class InvoiceAddCommonDetailsModelTemp {
  Data data;
  bool status;
  String message;

  InvoiceAddCommonDetailsModelTemp({
    required this.data,
    required this.status,
    required this.message,
  });

  factory InvoiceAddCommonDetailsModelTemp.fromJson(
          Map<String, dynamic> json) =>
      InvoiceAddCommonDetailsModelTemp(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  String customerId;
  int invoiceNumber;
  int checkId;
  String displayInvoice;
  String totalAmountDue;
  List<PaymentStatus> paymentStatus;
  List<PaymentMethod> paymentMethods;
  List<CompanyDetail> companyDetails;
  BillingAddress billingAddress;
  ShippingAddress shippingAddress;
  List<Product> products;
  List<Staff> staff;
  List<Template> template;
  bool createRenewal;
  List<TargetGroup> targetGroups;

  Data({
    required this.customerId,
    required this.invoiceNumber,
    required this.checkId,
    required this.displayInvoice,
    required this.totalAmountDue,
    required this.paymentStatus,
    required this.paymentMethods,
    required this.companyDetails,
    required this.billingAddress,
    required this.shippingAddress,
    required this.products,
    required this.staff,
    required this.template,
    required this.createRenewal,
    required this.targetGroups,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        customerId: json["customer_id"] ?? "",
        invoiceNumber: json["invoice_number"] ?? 0,
        checkId: json["check_id"] ?? 0,
        displayInvoice: json["display_invoice"] ?? "",
        totalAmountDue: json["total_amount_due"] ?? "",
        paymentStatus: json["payment_status"] is List
            ? List<PaymentStatus>.from(
                json["payment_status"].map((x) => PaymentStatus.fromJson(x)))
            : [],
        paymentMethods: json["payment_methods"] is List
            ? List<PaymentMethod>.from(
                json["payment_methods"].map((x) => PaymentMethod.fromJson(x)))
            : [],
        companyDetails: json["company_details"] is List
            ? List<CompanyDetail>.from(
                json["company_details"].map((x) => CompanyDetail.fromJson(x)))
            : [],
        billingAddress: BillingAddress.fromJson(json["billing_address"]),
        shippingAddress: ShippingAddress.fromJson(json["shipping_address"]),
        products: json["products"] is List
            ? List<Product>.from(
                json["products"].map((x) => Product.fromJson(x)))
            : [],
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
        template: List<Template>.from(
            json["template"].map((x) => Template.fromJson(x))),
        createRenewal: json["create_renewal"],
        targetGroups: List<TargetGroup>.from(
            json["target_groups"].map((x) => TargetGroup.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "invoice_number": invoiceNumber,
        "check_id": checkId,
        "display_invoice": displayInvoice,
        "total_amount_due": totalAmountDue,
        "payment_status":
            List<dynamic>.from(paymentStatus.map((x) => x.toJson())),
        "payment_methods":
            List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "company_details":
            List<dynamic>.from(companyDetails.map((x) => x.toJson())),
        "billing_address": billingAddress.toJson(),
        "shipping_address": shippingAddress.toJson(),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
        "template": List<dynamic>.from(template.map((x) => x.toJson())),
      };
}

class BillingAddress {
  String billingName;
  dynamic billingAddress;
  dynamic billingAddress2;
  dynamic billingAddress3;
  String billingCountryCode;
  String billingContactNo;
  String billingGst;
  String billingPincode;
  String billingPostOffice;

  BillingAddress({
    required this.billingName,
    required this.billingAddress,
      required this.billingAddress2,
        required this.billingAddress3,
    required this.billingCountryCode,
    required this.billingContactNo,
    required this.billingGst,
    required this.billingPincode,
    required this.billingPostOffice,
  });

  factory BillingAddress.fromJson(Map<String, dynamic> json) => BillingAddress(
        billingName: json["billing_name"] ?? "",
        billingAddress: json["billing_address"] ?? "",
          billingAddress2: json["billing_address2"] ?? "",
            billingAddress3: json["billing_address3"] ?? "",
        billingCountryCode: json["billing_country_code"] ?? "",
        billingContactNo: json["billing_contact_no"] ?? "",
        billingGst: json["billing_gst"] ?? "",
        billingPincode: json["billing_pincode"] ?? "",
        billingPostOffice: json["billing_post_office"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "billing_name": billingName,
        "billing_address": billingAddress,
         "billing_address2": billingAddress2,
          "billing_address3": billingAddress3,
        "billing_country_code": billingCountryCode,
        "billing_contact_no": billingContactNo,
        "billing_gst": billingGst,
        "billing_pincode": billingPincode,
        "billing_post_office": billingPostOffice,
      };
}

class CompanyDetail {
  String companyLogo;
  String companyAddress;
  String companyPincode;
  String companyRegNo;
  String companyEmail;
  String companyWebsite;
  String companyContactNo;

  CompanyDetail({
    required this.companyLogo,
    required this.companyAddress,
    required this.companyPincode,
    required this.companyRegNo,
    required this.companyEmail,
    required this.companyWebsite,
    required this.companyContactNo,
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> json) => CompanyDetail(
        companyLogo: json["company_logo"] ?? "",
        companyAddress: json["company_address"] ?? "",
        companyPincode: json["company_pincode"] ?? "",
        companyRegNo: json["company_reg_no"] ?? "",
        companyEmail: json["company_email"] ?? "",
        companyWebsite: json["company_website"] ?? "",
        companyContactNo: json["company_contact_no"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "company_logo": companyLogo,
        "company_address": companyAddress,
        "company_pincode": companyPincode,
        "company_reg_no": companyRegNo,
        "company_email": companyEmail,
        "company_website": companyWebsite,
        "company_contact_no": companyContactNo,
      };
}

class PaymentMethod {
  String id;
  String name;

  PaymentMethod({
    required this.id,
    required this.name,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class PaymentStatus {
  String paymentStatus;
  String displaySts;

  PaymentStatus({
    required this.paymentStatus,
    required this.displaySts,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
        paymentStatus: json["payment_status"] ?? "",
        displaySts: json["display_sts"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "payment_status": paymentStatus,
        "display_sts": displaySts,
      };
}

class Product {
  String id;
  String productName;
  String sellingPrice;
  String taxPercent;
  String taxAmount;
  String noOfDays;

  Product({
    required this.id,
    required this.productName,
    required this.sellingPrice,
    required this.taxPercent,
    required this.taxAmount,
    required this.noOfDays,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"] ?? "",
        productName: json["product_name"] ?? "",
        sellingPrice: json["selling_price"] ?? "",
        taxPercent: json["tax_percent"] ?? "",
        taxAmount: json["tax_amount"] ?? "",
        noOfDays: json["no_of_days"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "selling_price": sellingPrice,
        "tax_percent": taxPercent,
        "tax_amount": taxAmount,
        "no_of_days": noOfDays
      };
}

class ShippingAddress {
  String shippingName;
  dynamic shippingAddress;
   dynamic shippingAddress2;
    dynamic shippingAddress3;
  String shippingCountryCode;
  String shippingContactNo;
  String shippingGst;
  String shippingPincode;
  String shippingPostOffice;

  ShippingAddress({
    required this.shippingName,
    required this.shippingAddress,
     required this.shippingAddress2,
      required this.shippingAddress3,
    required this.shippingCountryCode,
    required this.shippingContactNo,
    required this.shippingGst,
    required this.shippingPincode,
    required this.shippingPostOffice,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      ShippingAddress(
        shippingName: json["shipping_name"] ?? "",
        shippingAddress: json["shipping_address"] ?? "",
         shippingAddress2: json["shipping_address2"] ?? "",
          shippingAddress3: json["shipping_address3"] ?? "",
        shippingCountryCode: json["shipping_country_code"] ?? "",
        shippingContactNo: json["shipping_contact_no"] ?? "",
        shippingGst: json["shipping_gst"] ?? "",
        shippingPincode: json["shipping_pincode"] ?? "",
        shippingPostOffice: json["shipping_post_office"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "shipping_name": shippingName,
        "shipping_address": shippingAddress,
         "shipping_address2": shippingAddress2,
          "shipping_address3": shippingAddress3,
        "shipping_country_code": shippingCountryCode,
        "shipping_contact_no": shippingContactNo,
        "shipping_gst": shippingGst,
        "shipping_pincode": shippingPincode,
        "shipping_post_office": shippingPostOffice,
      };
}

class Staff {
  String accountId;
  String accountName;

  Staff({
    required this.accountId,
    required this.accountName,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        accountId: json["account_id"] ?? "",
        accountName: json["account_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
      };
}

class Template {
  String id;
  String templateName;

  Template({
    required this.id,
    required this.templateName,
  });

  factory Template.fromJson(Map<String, dynamic> json) => Template(
        id: json["id"] ?? "",
        templateName: json["template_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "template_name": templateName,
      };
}

class TargetGroup {
  String id;
  String groupName;

  TargetGroup({
    required this.id,
    required this.groupName,
  });

  factory TargetGroup.fromJson(Map<String, dynamic> json) => TargetGroup(
        id: json["id"] ?? "",
        groupName: json["group_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "group_name": groupName,
      };
}
