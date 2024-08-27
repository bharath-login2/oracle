// To parse this JSON data, do
//
//     final expenseListModel = expenseListModelFromJson(jsonString);

import 'dart:convert';

ExpenseListModel expenseListModelFromJson(String str) =>
    ExpenseListModel.fromJson(json.decode(str));

String expenseListModelToJson(ExpenseListModel data) =>
    json.encode(data.toJson());

class ExpenseListModel {
  bool status;
  String message;
  List<Expense> data;

  ExpenseListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ExpenseListModel.fromJson(Map<String, dynamic> json) =>
      ExpenseListModel(
        status: json["status"],
        message: json["message"],
        data: List<Expense>.from(json["data"].map((x) => Expense.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Expense {
  String cmpnyExId;
  String expCatid;
  String fromAccount;
  String tothePerson;
  String amount;
  DateTime trnDate;
  String company;
  String remarks;
  String fromAccountPerson;
  String toAccountPerson;
  String expCatName;
  String staffName;

  Expense({
    required this.cmpnyExId,
    required this.expCatid,
    required this.fromAccount,
    required this.tothePerson,
    required this.amount,
    required this.trnDate,
    required this.company,
    required this.remarks,
    required this.fromAccountPerson,
    required this.toAccountPerson,
    required this.expCatName,
    required this.staffName,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        cmpnyExId: json["CmpnyExId"] ?? "",
        expCatid: json["ExpCatid"] ?? "",
        fromAccount: json["from_account"] ?? "",
        tothePerson: json["TothePerson"] ?? "",
        amount: json["Amount"] ?? "",
        trnDate: DateTime.parse(json["TrnDate"]),
        company: json["company"] ?? "",
        remarks: json["Remarks"] ?? "",
        fromAccountPerson: json["from_account_person"] ?? "",
        toAccountPerson: json["to_account_person"] ?? "",
        expCatName: json["ExpCatName"] ?? "",
        staffName: json["staff_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "CmpnyExId": cmpnyExId,
        "ExpCatid": expCatid,
        "from_account": fromAccount,
        "TothePerson": tothePerson,
        "Amount": amount,
        "TrnDate":
            "${trnDate.year.toString().padLeft(4, '0')}-${trnDate.month.toString().padLeft(2, '0')}-${trnDate.day.toString().padLeft(2, '0')}",
        "company": company,
        "Remarks": remarks,
        "from_account_person": fromAccountPerson,
        "to_account_person": toAccountPerson,
        "ExpCatName": expCatName,
        "staff_name": staffName,
      };
}
