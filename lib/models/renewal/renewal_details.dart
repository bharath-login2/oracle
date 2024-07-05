// To parse this JSON data, do
//
//     final renewalDetailslModel = renewalDetailslModelFromJson(jsonString);

import 'dart:convert';

RenewalDetailslModel renewalDetailslModelFromJson(String str) => RenewalDetailslModel.fromJson(json.decode(str));

String renewalDetailslModelToJson(RenewalDetailslModel data) => json.encode(data.toJson());

class RenewalDetailslModel {
    Data data;
    bool status;
    String message;

    RenewalDetailslModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory RenewalDetailslModel.fromJson(Map<String, dynamic> json) => RenewalDetailslModel(
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
    int invoiceNumber;
    String slNumber;
    int checkId;
    String displayInvoice;
    List<Customer> customer;
    List<PaymentStatus> paymentStatus;
    List<Customer> paymentMethods;
    List<Template> template;
    List<Staff> staff;
    List<Product> products;
    List<dynamic> branch;

    Data({
        required this.invoiceNumber,
        required this.slNumber,
        required this.checkId,
        required this.displayInvoice,
        required this.customer,
        required this.paymentStatus,
        required this.paymentMethods,
        required this.template,
        required this.staff,
        required this.products,
        required this.branch,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        invoiceNumber: json["invoice_number"],
        slNumber: json["sl_number"],
        checkId: json["check_id"],
        displayInvoice: json["display_invoice"],
        customer: List<Customer>.from(json["customer"].map((x) => Customer.fromJson(x))),
        paymentStatus: List<PaymentStatus>.from(json["payment_status"].map((x) => PaymentStatus.fromJson(x))),
        paymentMethods: List<Customer>.from(json["payment_methods"].map((x) => Customer.fromJson(x))),
        template: List<Template>.from(json["template"].map((x) => Template.fromJson(x))),
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
        branch: List<dynamic>.from(json["branch"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "invoice_number": invoiceNumber,
        "sl_number": slNumber,
        "check_id": checkId,
        "display_invoice": displayInvoice,
        "customer": List<dynamic>.from(customer.map((x) => x.toJson())),
        "payment_status": List<dynamic>.from(paymentStatus.map((x) => x.toJson())),
        "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "template": List<dynamic>.from(template.map((x) => x.toJson())),
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "branch": List<dynamic>.from(branch.map((x) => x)),
    };
}

class Customer {
    String id;
    String name;

    Customer({
        required this.id,
        required this.name,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
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
    String noOfDays;
    String taxAmount;

    Product({
        required this.id,
        required this.productName,
        required this.sellingPrice,
        required this.taxPercent,
        required this.noOfDays,
        required this.taxAmount,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productName: json["product_name"],
        sellingPrice: json["selling_price"],
        taxPercent: json["tax_percent"],
        noOfDays: json["no_of_days"],
        taxAmount: json["tax_amount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "selling_price": sellingPrice,
        "tax_percent": taxPercent,
        "no_of_days": noOfDays,
        "tax_amount": taxAmount,
    };
}

class Staff {
    String userId;
    String staffName;

    Staff({
        required this.userId,
        required this.staffName,
    });

    factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        userId: json["user_id"],
        staffName: json["staff_name"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
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
        id: json["id"],
        templateName: json["template_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "template_name": templateName,
    };
}
