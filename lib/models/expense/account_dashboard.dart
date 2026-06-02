// To parse this JSON data, do
//
//     final accountDashboardModel = accountDashboardModelFromJson(jsonString);

import 'dart:convert';

AccountDashboardModel accountDashboardModelFromJson(String str) =>
    AccountDashboardModel.fromJson(json.decode(str));

String accountDashboardModelToJson(AccountDashboardModel data) =>
    json.encode(data.toJson());

class AccountDashboardModel {
  bool status;
  String message;
  Data data;

  AccountDashboardModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AccountDashboardModel.fromJson(Map<String, dynamic> json) =>
      AccountDashboardModel(
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
  bool isViewAccHead;
  bool isViewBankAcc;
  bool isViewPendingExpense;
  ProfitAndLoss? profitAndLoss;
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
    required this.isViewAccHead,
    required this.isViewBankAcc,
    required this.isViewPendingExpense,
    this.profitAndLoss,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        todayExpense: json["todayExpense"]?.toString() ?? "",
        monthlyExpense: json["monthlyExpense"]?.toString() ?? "",
        pendingExpense: json["pendingExpense"]?.toString() ?? "",
        advanceAmount: json["advanceAmount"]?.toString() ?? "",
        bankAccount: json["BankAccount"]?.toString() ?? "",
        todaysIncome: json["todaysIncome"]?.toString() ?? "",
        monthlyIncome: json["monthlyIncome"]?.toString() ?? "",
        pendingIncome: json["pendingIncome"]?.toString() ?? "",
        bankAccCount: json["bank_acc_count"]?.toString() ?? "",
        bankAccountId: json["bank_account_id"]?.toString() ?? "",
        bankAccountName: json["bank_account_name"]?.toString() ?? "",
        isViewAccHead: json["is_view_acc_head"] == true || json["is_view_acc_head"] == "true" || json["is_view_acc_head"] == 1 || json["is_view_acc_head"] == "1",
        isViewBankAcc: json["is_view_bank_acc"] == true || json["is_view_bank_acc"] == "true" || json["is_view_bank_acc"] == 1 || json["is_view_bank_acc"] == "1",
        isViewPendingExpense: json["is_view_pending_expense"] == true || json["is_view_pending_expense"] == "true" || json["is_view_pending_expense"] == 1 || json["is_view_pending_expense"] == "1",
        profitAndLoss: json["profit_and_loss"] != null
            ? ProfitAndLoss.fromJson(json["profit_and_loss"])
            : null,
        incomeGraph:
            (json["income_graph"] != null && json["income_graph"] is List)
                ? List<IncomeGraph>.from(
                    json["income_graph"].map((x) => IncomeGraph.fromJson(x)))
                : [],
        expenseGraph:
            (json["expense_graph"] != null && json["expense_graph"] is List)
                ? List<ExpenseGraph>.from(
                    json["expense_graph"].map((x) => ExpenseGraph.fromJson(x)))
                : [],
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
        "is_view_acc_head": isViewAccHead,
        "is_view_bank_acc": isViewBankAcc,
        "is_view_pending_expense": isViewPendingExpense,
        "profit_and_loss": profitAndLoss?.toJson(),
        "income_graph": List<dynamic>.from(incomeGraph.map((x) => x.toJson())),
        "expense_graph":
            List<dynamic>.from(expenseGraph.map((x) => x.toJson())),
      };
}

class ProfitAndLoss {
  String type;
  String amount;
  String openingBalance;
  String closingBalance;
  IncomeExpense incomeExpense;

  ProfitAndLoss({
    required this.type,
    required this.amount,
    required this.openingBalance,
    required this.closingBalance,
    required this.incomeExpense,
  });

  factory ProfitAndLoss.fromJson(Map<String, dynamic> json) => ProfitAndLoss(
        type: json["type"]?.toString() ?? "",
        amount: json["amount"]?.toString() ?? "",
        openingBalance: json["opening_balance"]?.toString() ?? "",
        closingBalance: json["closing_balance"]?.toString() ?? "",
        incomeExpense: IncomeExpense.fromJson(json["income_expense"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "amount": amount,
        "opening_balance": openingBalance,
        "closing_balance": closingBalance,
        "income_expense": incomeExpense.toJson(),
      };
}

class IncomeExpense {
  Income income;
  Expense expense;

  IncomeExpense({
    required this.income,
    required this.expense,
  });

  factory IncomeExpense.fromJson(Map<String, dynamic> json) => IncomeExpense(
        income: Income.fromJson(json["income"] ?? {}),
        expense: Expense.fromJson(json["expense"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "income": income.toJson(),
        "expense": expense.toJson(),
      };
}

class Income {
  String receipt;
  String totalIncome;

  Income({
    required this.receipt,
    required this.totalIncome,
  });

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        receipt: json["receipt"]?.toString() ?? "",
        totalIncome: json["total_income"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "receipt": receipt,
        "total_income": totalIncome,
      };
}

class Expense {
  String expense;
  String advance;
  String lastMonthAdvance;
  String difference;
  String netExpense;

  Expense({
    required this.expense,
    required this.advance,
    required this.lastMonthAdvance,
    required this.difference,
    required this.netExpense,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        expense: json["expense"]?.toString() ?? "",
        advance: json["advance"]?.toString() ?? "",
        lastMonthAdvance: json["last_month_advance"]?.toString() ?? "",
        difference: json["difference"]?.toString() ?? "",
        netExpense: json["net_expense"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "expense": expense,
        "advance": advance,
        "last_month_advance": lastMonthAdvance,
        "difference": difference,
        "net_expense": netExpense,
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
        totalExpense: json["totalExpense"]?.toString() ?? "",
        expCatid: json["ExpCatid"]?.toString() ?? "",
        expCatName: json["ExpCatName"]?.toString() ?? "",
        perc: json["perc"]?.toString() ?? "",
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
        type: json["type"]?.toString() ?? "",
        totalExpense: json["totalExpense"]?.toString() ?? "",
        category: json["category"]?.toString() ?? "",
        perc: json["perc"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "totalExpense": totalExpense,
        "category": category,
        "perc": perc,
      };
}
