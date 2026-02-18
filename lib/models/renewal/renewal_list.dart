// To parse this JSON data, do
//
//     final renewalListModel = renewalListModelFromJson(jsonString);

import 'dart:convert';

RenewalListModel renewalListModelFromJson(String str) =>
    RenewalListModel.fromJson(json.decode(str));

String renewalListModelToJson(RenewalListModel data) =>
    json.encode(data.toJson());

class RenewalListModel {
  Data data;
  bool status;
  String message;

  RenewalListModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory RenewalListModel.fromJson(Map<String, dynamic> json) =>
      RenewalListModel(
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
  List<Count> count;

  Data({
    required this.lists,
    required this.recordCount,
    required this.count,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(
            json["lists"].map((x) => ListElement.fromJson(x))),
        recordCount: json["record_count"],
        count: List<Count>.from(json["count"].map((x) => Count.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "record_count": recordCount,
        "count": List<dynamic>.from(count.map((x) => x.toJson())),
      };
}

class ListElement {
  String id;
  String clientId;
  String clientName;
  String contactNo;
  String startDate;
  String endDate;
  String invoiceId;
  String remainingDays;
  String products;
  String cost;
  bool isRenewed;
  bool isExpired;
  bool isPaid;
  String renewalType;
  List<ProductId> productId;
  String renewedDate;
  String renewedBy;

  ListElement({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.contactNo,
    required this.startDate,
    required this.endDate,
    required this.invoiceId,
    required this.remainingDays,
    required this.products,
    required this.cost,
    required this.isRenewed,
    required this.isExpired,
    required this.isPaid,
    required this.renewalType,
    required this.productId,
    required this.renewedDate,
    required this.renewedBy,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        clientId: json["client_id"],
        clientName: json["client_name"],
        contactNo: json["contact_no"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        invoiceId: json["invoice_id"],
        remainingDays: json["remaining_days"],
        products: json["products"],
        cost: json["cost"],
        isRenewed: json["is_renewed"],
        isExpired: json["is_expired"],
        isPaid: json["is_paid"],
        renewalType: json["renewal_type"],
        productId: List<ProductId>.from(
            json["product_id"].map((x) => ProductId.fromJson(x))),
        renewedDate: json["renewed_date"],
        renewedBy: json["renewed_by"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_id": clientId,
        "client_name": clientName,
        "contact_no": contactNo,
        "start_date": startDate,
        "end_date": endDate,
        "remaining_days": remainingDays,
        "products": products,
        "cost": cost,
        "is_renewed": isRenewed,
        "is_expired": isExpired,
        "is_paid": isPaid,
        "renewal_type": renewalType,
        "product_id": List<dynamic>.from(productId.map((x) => x.toJson())),
        "renewed_date": renewedDate,
        "renewed_by": renewedBy,
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
        prdName: json["prd_name"],
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

class Count {
  String totalCount;
  String totalAmount;
  Renewed renewed;
  Expired expired;
  Pending pending;

  Count({
    required this.totalCount,
    required this.totalAmount,
    required this.renewed,
    required this.expired,
    required this.pending,
  });

  factory Count.fromJson(Map<String, dynamic> json) => Count(
        totalCount: json["total_count"],
        totalAmount: json["total_amount"],
        renewed: Renewed.fromJson(json["renewed"]),
        expired: Expired.fromJson(json["expired"]),
        pending: Pending.fromJson(json["pending"]),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "total_amount": totalAmount,
        "renewed": renewed.toJson(),
        "expired": expired.toJson(),
        "pending": pending.toJson(),
      };
}

class Renewed {
  String total;
  String amount;

  Renewed({
    required this.total,
    required this.amount,
  });

  factory Renewed.fromJson(Map<String, dynamic> json) => Renewed(
        total: json["total"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "amount": amount,
      };
}

class Expired {
  String total;
  String amount;

  Expired({
    required this.total,
    required this.amount,
  });

  factory Expired.fromJson(Map<String, dynamic> json) => Expired(
        total: json["total"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "amount": amount,
      };
}

class Pending {
  String total;
  String amount;

  Pending({
    required this.total,
    required this.amount,
  });

  factory Pending.fromJson(Map<String, dynamic> json) => Pending(
        total: json["total"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "amount": amount,
      };
}
