// To parse this JSON data, do
//
//     final bankAccountList = bankAccountListFromJson(jsonString);

import 'dart:convert';

BankAccountList bankAccountListFromJson(String str) =>
    BankAccountList.fromJson(json.decode(str));

class BankAccountList {
  Data data;
  bool status;
  String message;

  BankAccountList({
    required this.data,
    required this.status,
    required this.message,
  });

  factory BankAccountList.fromJson(Map<String, dynamic> json) =>
      BankAccountList(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );
}

class Data {
  List<ListElement> lists;
  String totalCredit;
  String toalDebit;
  String advance;
  String openingBalance;
  String closingBalance;

  Data({
    required this.lists,
    required this.totalCredit,
    required this.toalDebit,
    required this.advance,
    required this.openingBalance,
    required this.closingBalance,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(
            json["lists"].map((x) => ListElement.fromJson(x))),
        totalCredit: json["total_credit"],
        toalDebit: json["toal_debit"],
        advance: json["advance"],
        openingBalance: json["opening_balance"],
        closingBalance: json["closing_balance"],
      );
}

class ListElement {
  String createdDate;
  String accountName;
  String createdStaff;
  String title;
  String remarks;
  String type;
  String amount;

  ListElement({
    required this.createdDate,
    required this.accountName,
    required this.createdStaff,
    required this.title,
    required this.remarks,
    required this.type,
    required this.amount,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        createdDate: json["created_date"],
        accountName: json["account_name"],
        createdStaff: json["created_staff"],
        title: json["title"],
        remarks: json["remarks"],
        type: json["type"],
        amount: json["amount"],
      );
}
