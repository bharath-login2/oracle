import 'dart:convert';

import 'package:flutter/material.dart';

RentalReturnModel rentalReturnModelFromJson(String str) =>
    RentalReturnModel.fromJson(json.decode(str));

String rentalReturnModelToJson(RentalReturnModel data) =>
    json.encode(data.toJson());

class RentalReturnModel {
  final bool status;
  final String message;
  final RentalReturnData data;

  RentalReturnModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentalReturnModel.fromJson(Map<String, dynamic> json) =>
      RentalReturnModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: RentalReturnData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class RentalReturnData {
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final List<RentalReturnItem> list;

  RentalReturnData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.list,
  });

  factory RentalReturnData.fromJson(Map<String, dynamic> json) =>
      RentalReturnData(
        draw: json["draw"] ?? 0,
        recordsTotal: json["recordsTotal"] ?? 0,
        recordsFiltered: json["recordsFiltered"] ?? 0,
        list: List<RentalReturnItem>.from(
          (json["list"] ?? []).map((x) => RentalReturnItem.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "draw": draw,
        "recordsTotal": recordsTotal,
        "recordsFiltered": recordsFiltered,
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
      };
}

class RentalReturnItem {
  final int slNo;
  final int returnId;
  final String customerStaffId;
  final String customerStaffName;
  final String returnNo;
  final String invoiceNo;
  final String returnDate;
   final String customerId;
  final String customerName;
  final int issuedQty;
  final int returnedQty;
  final int balanceQty;
  final String status;

  RentalReturnItem({
    required this.slNo,
    required this.returnId,
    required this.customerStaffId,
    required this.customerStaffName,
    required this.returnNo,
    required this.invoiceNo,
    required this.returnDate,
    required this.customerId,
    required this.customerName,
    required this.issuedQty,
    required this.returnedQty,
    required this.balanceQty,
    required this.status,
  });

  factory RentalReturnItem.fromJson(Map<String, dynamic> json) =>
      RentalReturnItem(
        slNo: json["sl_no"] ?? 0,
        returnId: json["return_id"] ?? 0,
        customerStaffId: json["customer_staff_id"] ?? 0,
        customerStaffName: json["customer_staff_name"] ?? "",
        returnNo: json["return_no"] ?? "",
        invoiceNo: json["invoice_no"] ?? "",
        returnDate: json["return_date"] ?? "",
        customerId: json["customer_id"] ?? "",
        customerName: json["customer_name"] ?? "",
        issuedQty: json["issued_qty"] ?? 0,
        returnedQty: json["returned_qty"] ?? 0,
        balanceQty: json["balance_qty"] ?? 0,
        status: json["status"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "sl_no": slNo,
        "return_id": returnId,
        "customer_staff_id": customerStaffId,
        "customer_staff_name": customerStaffName,
        "return_no": returnNo,
        "invoice_no": invoiceNo,
        "return_date": returnDate,
        "customer_id": customerId,
        "customer_name": customerName,
        "issued_qty": issuedQty,
        "returned_qty": returnedQty,
        "balance_qty": balanceQty,
        "status": status,
      };
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';

  bool get hasExcessReturn => balanceQty < 0;
  bool get hasBalance => balanceQty > 0;
  bool get isFullyReturned => balanceQty == 0;

  double get returnPercentage {
    if (issuedQty == 0) return 0.0;
    return (returnedQty / issuedQty * 100);
  }

  String get returnStatusText {
    if (isCompleted) {
      if (hasExcessReturn) {
        return 'Excess Return';
      } else if (isFullyReturned) {
        return 'Fully Returned';
      } else {
        return 'Completed';
      }
    }
    return status;
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return hasExcessReturn ? Colors.orange : Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'completed':
        return hasExcessReturn ? Icons.warning : Icons.check_circle;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }
}
