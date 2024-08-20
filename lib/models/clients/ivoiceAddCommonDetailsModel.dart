// To parse this JSON data, do
//
//     final invoiceAddCommonDetailsModel = invoiceAddCommonDetailsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

InvoiceAddCommonDetailsModel invoiceAddCommonDetailsModelFromJson(String str) => InvoiceAddCommonDetailsModel.fromJson(json.decode(str));

String invoiceAddCommonDetailsModelToJson(InvoiceAddCommonDetailsModel data) => json.encode(data.toJson());

class InvoiceAddCommonDetailsModel {
    Data data;
    bool status;
    String message;

    InvoiceAddCommonDetailsModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory InvoiceAddCommonDetailsModel.fromJson(Map<String, dynamic> json) => InvoiceAddCommonDetailsModel(
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
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        customerId: json["customer_id"],
        invoiceNumber: json["invoice_number"],
        checkId: json["check_id"],
        displayInvoice: json["display_invoice"],
        totalAmountDue: json["total_amount_due"],
        paymentStatus: List<PaymentStatus>.from(json["payment_status"].map((x) => PaymentStatus.fromJson(x))),
        paymentMethods: List<PaymentMethod>.from(json["payment_methods"].map((x) => PaymentMethod.fromJson(x))),
        companyDetails: List<CompanyDetail>.from(json["company_details"].map((x) => CompanyDetail.fromJson(x))),
        billingAddress: BillingAddress.fromJson(json["billing_address"]),
        shippingAddress: ShippingAddress.fromJson(json["shipping_address"]),
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "invoice_number": invoiceNumber,
        "check_id": checkId,
        "display_invoice": displayInvoice,
        "total_amount_due": totalAmountDue,
        "payment_status": List<dynamic>.from(paymentStatus.map((x) => x.toJson())),
        "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "company_details": List<dynamic>.from(companyDetails.map((x) => x.toJson())),
        "billing_address": billingAddress.toJson(),
        "shipping_address": shippingAddress.toJson(),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
    };
}

class BillingAddress {
    String billingName;
    dynamic billingAddress;
    String billingCountryCode;
    String billingContactNo;
    String billingGst;
    String billingPincode;
    String billingPostOffice;

    BillingAddress({
        required this.billingName,
        required this.billingAddress,
        required this.billingCountryCode,
        required this.billingContactNo,
        required this.billingGst,
        required this.billingPincode,
        required this.billingPostOffice,
    });

    factory BillingAddress.fromJson(Map<String, dynamic> json) => BillingAddress(
        billingName: json["billing_name"],
        billingAddress: json["billing_address"],
        billingCountryCode: json["billing_country_code"],
        billingContactNo: json["billing_contact_no"],
        billingGst: json["billing_gst"],
        billingPincode: json["billing_pincode"],
        billingPostOffice: json["billing_post_office"],
    );

    Map<String, dynamic> toJson() => {
        "billing_name": billingName,
        "billing_address": billingAddress,
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
        companyLogo: json["company_logo"],
        companyAddress: json["company_address"],
        companyPincode: json["company_pincode"],
        companyRegNo: json["company_reg_no"],
        companyEmail: json["company_email"],
        companyWebsite: json["company_website"],
        companyContactNo: json["company_contact_no"],
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
        paymentStatus: json["payment_status"],
        displaySts: json["display_sts"],
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

    Product({
        required this.id,
        required this.productName,
        required this.sellingPrice,
        required this.taxPercent,
        required this.taxAmount,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productName: json["product_name"],
        sellingPrice: json["selling_price"],
        taxPercent: json["tax_percent"],
        taxAmount: json["tax_amount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "selling_price": sellingPrice,
        "tax_percent": taxPercent,
        "tax_amount": taxAmount,
    };
}

class ShippingAddress {
    String shippingName;
    dynamic shippingAddress;
    String shippingCountryCode;
    String shippingContactNo;
    String shippingGst;
    String shippingPincode;
    String shippingPostOffice;

    ShippingAddress({
        required this.shippingName,
        required this.shippingAddress,
        required this.shippingCountryCode,
        required this.shippingContactNo,
        required this.shippingGst,
        required this.shippingPincode,
        required this.shippingPostOffice,
    });

    factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
        shippingName: json["shipping_name"],
        shippingAddress: json["shipping_address"],
        shippingCountryCode: json["shipping_country_code"],
        shippingContactNo: json["shipping_contact_no"],
        shippingGst: json["shipping_gst"],
        shippingPincode: json["shipping_pincode"],
        shippingPostOffice: json["shipping_post_office"],
    );

    Map<String, dynamic> toJson() => {
        "shipping_name": shippingName,
        "shipping_address": shippingAddress,
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
        accountId: json["account_id"],
        accountName: json["account_name"],
    );

    Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
    };
}
