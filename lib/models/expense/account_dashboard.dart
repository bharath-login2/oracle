// To parse this JSON data, do
//
//     final accountDashboardModel = accountDashboardModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

AccountDashboardModel accountDashboardModelFromJson(String str) => AccountDashboardModel.fromJson(json.decode(str));

String accountDashboardModelToJson(AccountDashboardModel data) => json.encode(data.toJson());

class AccountDashboardModel {
    bool status;
    String message;
    Data data;

    AccountDashboardModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory AccountDashboardModel.fromJson(Map<String, dynamic> json) => AccountDashboardModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String todayExpense;
    String monthlyExpense;
    String pendingExpense;
    String advanceAmount;
    String bankAccount;
    String todaysIncome;
    String monthlyIncome;
    String pendingIncome;
    String bankAccCount;
    String bankAccountId;
    String bankAccountName;
    List<IncomeGraph> incomeGraph;
    List<ExpenseGraph> expenseGraph;

    Data({
        required this.todayExpense,
        required this.monthlyExpense,
        required this.pendingExpense,
        required this.advanceAmount,
        required this.bankAccount,
        required this.todaysIncome,
        required this.monthlyIncome,
        required this.pendingIncome,
        required this.bankAccCount,
        required this.bankAccountId,
        required this.bankAccountName,
        required this.incomeGraph,
        required this.expenseGraph,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        todayExpense: json["todayExpense"],
        monthlyExpense: json["monthlyExpense"],
        pendingExpense: json["pendingExpense"],
        advanceAmount: json["advanceAmount"],
        bankAccount: json["BankAccount"],
        todaysIncome: json["todaysIncome"],
        monthlyIncome: json["monthlyIncome"],
        pendingIncome: json["pendingIncome"],
        bankAccCount: json["bank_acc_count"],
        bankAccountId: json["bank_account_id"],
        bankAccountName: json["bank_account_name"],
        incomeGraph: List<IncomeGraph>.from(json["income_graph"].map((x) => IncomeGraph.fromJson(x))),
        expenseGraph: List<ExpenseGraph>.from(json["expense_graph"].map((x) => ExpenseGraph.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "todayExpense": todayExpense,
        "monthlyExpense": monthlyExpense,
        "pendingExpense": pendingExpense,
        "advanceAmount": advanceAmount,
        "BankAccount": bankAccount,
        "todaysIncome": todaysIncome,
        "monthlyIncome": monthlyIncome,
        "pendingIncome": pendingIncome,
        "bank_acc_count": bankAccCount,
        "bank_account_id": bankAccountId,
        "bank_account_name": bankAccountName,
        "income_graph": List<dynamic>.from(incomeGraph.map((x) => x.toJson())),
        "expense_graph": List<dynamic>.from(expenseGraph.map((x) => x.toJson())),
    };
}

class ExpenseGraph {
    String totalExpense;
    String expCatid;
    String expCatName;
    String perc;

    ExpenseGraph({
        required this.totalExpense,
        required this.expCatid,
        required this.expCatName,
        required this.perc,
    });

    factory ExpenseGraph.fromJson(Map<String, dynamic> json) => ExpenseGraph(
        totalExpense: json["totalExpense"],
        expCatid: json["ExpCatid"],
        expCatName: json["ExpCatName"],
        perc: json["perc"],
    );

    Map<String, dynamic> toJson() => {
        "totalExpense": totalExpense,
        "ExpCatid": expCatid,
        "ExpCatName": expCatName,
        "perc": perc,
    };
}

class IncomeGraph {
    String type;
    String totalExpense;
    String category;
    String perc;

    IncomeGraph({
        required this.type,
        required this.totalExpense,
        required this.category,
        required this.perc,
    });

    factory IncomeGraph.fromJson(Map<String, dynamic> json) => IncomeGraph(
        type: json["type"],
        totalExpense: json["totalExpense"],
        category: json["category"],
        perc: json["perc"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "totalExpense": totalExpense,
        "category": category,
        "perc": perc,
    };
}
