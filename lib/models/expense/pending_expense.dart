// To parse this JSON data, do
//
//     final pendingExpenseModel = pendingExpenseModelFromJson(jsonString);

import 'dart:convert';

PendingExpenseModel pendingExpenseModelFromJson(String str) => PendingExpenseModel.fromJson(json.decode(str));

String pendingExpenseModelToJson(PendingExpenseModel data) => json.encode(data.toJson());

class PendingExpenseModel {
    Data data;
    bool status;
    String message;

    PendingExpenseModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory PendingExpenseModel.fromJson(Map<String, dynamic> json) => PendingExpenseModel(
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
    double totalAmount;

    Data({
        required this.lists,
        required this.totalAmount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        totalAmount: json["total_amount"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "total_amount": totalAmount,
    };
}

class ListElement {
    String accountName;
    String accountId;
    String totDebit;
    String totCredit;
    String balanceAmount;

    ListElement({
        required this.accountName,
        required this.accountId,
        required this.totDebit,
        required this.totCredit,
        required this.balanceAmount,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        accountName: json["account_name"],
        accountId: json["account_id"],
        totDebit: json["tot_debit"],
        totCredit: json["tot_credit"],
        balanceAmount: json["balance_amount"],
    );

    Map<String, dynamic> toJson() => {
        "account_name": accountName,
        "account_id": accountId,
        "tot_debit": totDebit,
        "tot_credit": totCredit,
        "balance_amount": balanceAmount,
    };
}
