// To parse this JSON data, do
//
//     final renewalTemplateModel = renewalTemplateModelFromJson(jsonString);

import 'dart:convert';

RenewalTemplateModel renewalTemplateModelFromJson(String str) => RenewalTemplateModel.fromJson(json.decode(str));

String renewalTemplateModelToJson(RenewalTemplateModel data) => json.encode(data.toJson());

class RenewalTemplateModel {
    Data data;
    bool status;
    String message;

    RenewalTemplateModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory RenewalTemplateModel.fromJson(Map<String, dynamic> json) => RenewalTemplateModel(
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
    String renewalId;
    String customerName;
    String customerId;
    String phoneNumber;
    String templateId;
    String templateType;
    String templateName;
    String medium;
    String message;

    Data({
        required this.renewalId,
        required this.customerName,
        required this.customerId,
        required this.phoneNumber,
        required this.templateId,
        required this.templateType,
        required this.templateName,
        required this.medium,
        required this.message,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        renewalId: json["renewal_id"],
        customerName: json["customer_name"],
        customerId: json["customer_id"],
        phoneNumber: json["phone_number"],
        templateId: json["template_id"],
        templateType: json["template_type"],
        templateName: json["template_name"],
        medium: json["medium"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "renewal_id": renewalId,
        "customer_name": customerName,
        "customer_id": customerId,
        "phone_number": phoneNumber,
        "template_id": templateId,
        "template_type": templateType,
        "template_name": templateName,
        "medium": medium,
        "message": message,
    };
}
