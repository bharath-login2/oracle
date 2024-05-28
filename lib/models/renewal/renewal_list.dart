// To parse this JSON data, do
//
//     final renewalListModel = renewalListModelFromJson(jsonString);

import 'dart:convert';

RenewalListModel renewalListModelFromJson(String str) => RenewalListModel.fromJson(json.decode(str));

String renewalListModelToJson(RenewalListModel data) => json.encode(data.toJson());

class RenewalListModel {
    Data data;
    bool status;
    String message;

    RenewalListModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory RenewalListModel.fromJson(Map<String, dynamic> json) => RenewalListModel(
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
    List<ListElement> lists;
    int recordCount;

    Data({
        required this.lists,
        required this.recordCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        recordCount: json["record_count"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "record_count": recordCount,
    };
}

class ListElement {
    String id;
    String templateId;
    String templateName;
    String invoiceId;
    String clientName;
    String clientId;
    String startDate;
    String endDate;
    bool isExpired;
    bool isRenewed;
    String remainingDays;
    String products;
    List<ProductId> productId;
    String contactNo;
    String cost;
    String remarks;
    String noOfDays;
    bool isInvoiceCreated;
    bool isInvoicePaid;

    ListElement({
        required this.id,
        required this.templateId,
        required this.templateName,
        required this.invoiceId,
        required this.clientName,
        required this.clientId,
        required this.startDate,
        required this.endDate,
        required this.isExpired,
        required this.isRenewed,
        required this.remainingDays,
        required this.products,
        required this.productId,
        required this.contactNo,
        required this.cost,
        required this.remarks,
        required this.noOfDays,
        required this.isInvoiceCreated,
        required this.isInvoicePaid,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        templateId: json["template_id"],
        templateName: json["template_name"],
        invoiceId: json["invoice_id"],
        clientName: json["client_name"],
        clientId: json["client_id"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        isExpired: json["is_expired"],
        isRenewed: json["is_renewed"],
        remainingDays: json["remaining_days"],
        products: json["products"],
        productId: List<ProductId>.from(json["product_id"].map((x) => ProductId.fromJson(x))),
        contactNo: json["contact_no"],
        cost: json["cost"],
        remarks: json["remarks"],
        noOfDays: json["no_of_days"],
        isInvoiceCreated: json["is_invoice_created"],
        isInvoicePaid: json["is_invoice_paid"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "template_id": templateId,
        "template_name": templateName,
        "invoice_id": invoiceId,
        "client_name": clientName,
        "client_id": clientId,
        "start_date": startDate,
        "end_date": endDate,
        "is_expired": isExpired,
        "is_renewed": isRenewed,
        "remaining_days": remainingDays,
        "products": products,
        "product_id": List<dynamic>.from(productId.map((x) => x.toJson())),
        "contact_no": contactNo,
        "cost": cost,
        "remarks": remarks,
        "no_of_days": noOfDays,
        "is_invoice_created": isInvoiceCreated,
        "is_invoice_paid": isInvoicePaid,
    };
}

class ProductId {
    String prdId;
    String prdName;
    String prdCost;
    String prdQty;

    ProductId({
        required this.prdId,
        required this.prdName,
        required this.prdCost,
        required this.prdQty,
    });

    factory ProductId.fromJson(Map<String, dynamic> json) => ProductId(
        prdId: json["prd_id"],
        prdName:json["prd_name"],
        prdCost: json["prd_cost"],
        prdQty: json["prd_qty"],
    );

    Map<String, dynamic> toJson() => {
        "prd_id": prdId,
        "prd_name": prdName,
        "prd_cost": prdCost,
        "prd_qty": prdQty,
    };
}


