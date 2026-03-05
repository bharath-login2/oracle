import 'dart:convert';

RentIssueModel rentIssueModelFromJson(String str) =>
    RentIssueModel.fromJson(json.decode(str));

String rentIssueModelToJson(RentIssueModel data) => json.encode(data.toJson());

class RentIssueModel {
  final bool status;
  final String message;
  final RentIssueData data;

  RentIssueModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentIssueModel.fromJson(Map<String, dynamic> json) => RentIssueModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: RentIssueData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class RentIssueData {
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final List<RentItem> list;

  RentIssueData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.list,
  });

  factory RentIssueData.fromJson(Map<String, dynamic> json) => RentIssueData(
        draw: json["draw"] ?? 0,
        recordsTotal: json["recordsTotal"] ?? 0,
        recordsFiltered: json["recordsFiltered"] ?? 0,
        list: List<RentItem>.from(
          (json["list"] ?? []).map((x) => RentItem.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "draw": draw,
        "recordsTotal": recordsTotal,
        "recordsFiltered": recordsFiltered,
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
      };
}

class RentItem {
  final int slNo;
  final String rentId;
  final String rentNo;
  final String invoiceNo;
  final String fromDate;
  final String toDate;
  final String customerName;
  final String customerId;
  final String locationId;
  final int totalQty;
  final double grandTotal;
  final double amountPaid;
  final double balance;
  final String status;
  final int daysLeft;
  final String daysLabel;

  RentItem({
    required this.slNo,
    required this.rentId,
    required this.rentNo,
    required this.invoiceNo,
    required this.fromDate,
    required this.toDate,
    required this.customerName,
    required this.customerId,
    required this.locationId,
    required this.totalQty,
    required this.grandTotal,
    required this.amountPaid,
    required this.balance,
    required this.status,
    required this.daysLeft,
    required this.daysLabel,
  });

  factory RentItem.fromJson(Map<String, dynamic> json) => RentItem(
        slNo: json["sl_no"] ?? 0,
        rentId: json["rent_id"]?.toString() ?? "",
        rentNo: json["rent_no"] ?? "",
        invoiceNo: json["invoice_no"] ?? "",
        fromDate: json["from_date"] ?? "",
        toDate: json["to_date"] ?? "",
        customerName: json["customer_name"] ?? "",
        customerId: json["customer_id"]?.toString() ?? "",
        locationId: json["location_id"]?.toString() ?? "",
        totalQty: json["total_qty"] ?? 0,
        grandTotal: (json["grand_total"] ?? 0).toDouble(),
        amountPaid: (json["amount_paid"] ?? 0).toDouble(),
        balance: (json["balance"] ?? 0).toDouble(),
        status: json["status"] ?? "",
        daysLeft: json["days_left"] ?? 0,
        daysLabel: json["days_label"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "sl_no": slNo,
        "rent_id": rentId,
        "rent_no": rentNo,
        "invoice_no": invoiceNo,
        "from_date": fromDate,
        "to_date": toDate,
        "customer_name": customerName,
        "customer_id": customerId,
        "location_id": locationId,
        "total_qty": totalQty,
        "grand_total": grandTotal,
        "amount_paid": amountPaid,
        "balance": balance,
        "status": status,
        "days_left": daysLeft,
        "days_label": daysLabel,
      };

  bool get isExpired => daysLeft < 0;

  bool get isActive => daysLeft >= 0;

  bool get isFullyPaid => balance <= 0;

  bool get isPartiallyPaid => amountPaid > 0 && balance > 0;

  bool get isUnpaid => amountPaid == 0;

  double get paymentPercentage {
    if (grandTotal == 0) return 0.0;
    return (amountPaid / grandTotal * 100);
  }
}
