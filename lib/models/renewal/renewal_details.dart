// To parse this JSON data, do
//
//     final renewalDetailslModel = renewalDetailslModelFromJson(jsonString);

import 'package:meta/meta.dart';
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
    List<RenewalProduct> renewalProducts;
    List<Customer> customers;
    List<Template> template;

    Data({
        required this.renewalProducts,
        required this.customers,
        required this.template,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        renewalProducts: List<RenewalProduct>.from(json["renewal_products"].map((x) => RenewalProduct.fromJson(x))),
        customers: List<Customer>.from(json["customers"].map((x) => Customer.fromJson(x))),
        template: List<Template>.from(json["template"].map((x) => Template.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "renewal_products": List<dynamic>.from(renewalProducts.map((x) => x.toJson())),
        "customers": List<dynamic>.from(customers.map((x) => x.toJson())),
        "template": List<dynamic>.from(template.map((x) => x.toJson())),
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

class RenewalProduct {
    String id;
    String productName;
    String totalAmount;
    String noOfDays;
    String remindBefore;

    RenewalProduct({
        required this.id,
        required this.productName,
        required this.totalAmount,
        required this.noOfDays,
        required this.remindBefore,
    });

    factory RenewalProduct.fromJson(Map<String, dynamic> json) => RenewalProduct(
        id: json["id"],
        productName: json["product_name"],
        totalAmount: json["total_amount"],
        noOfDays: json["no_of_days"],
        remindBefore: json["remind_before"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "total_amount": totalAmount,
        "no_of_days": noOfDays,
        "remind_before": remindBefore,
    };
}

class Template {
    String templateId;
    String templateName;

    Template({
        required this.templateId,
        required this.templateName,
    });

    factory Template.fromJson(Map<String, dynamic> json) => Template(
        templateId: json["template_id"],
        templateName: json["template_name"],
    );

    Map<String, dynamic> toJson() => {
        "template_id": templateId,
        "template_name": templateName,
    };
}
