// To parse this JSON data, do
//
//     final expensehistoryModel = expensehistoryModelFromJson(jsonString);

import 'dart:convert';

ExpensehistoryModel expensehistoryModelFromJson(String str) =>
    ExpensehistoryModel.fromJson(json.decode(str));

String expensehistoryModelToJson(ExpensehistoryModel data) =>
    json.encode(data.toJson());

class ExpensehistoryModel {
  bool status;
  String message;
  Data data;

  ExpensehistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ExpensehistoryModel.fromJson(Map<String, dynamic> json) =>
      ExpensehistoryModel(
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
  String category;
  String expenseDate;
  String amount;
  List<History> history;

  Data({
    required this.category,
    required this.expenseDate,
    required this.amount,
    required this.history,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        category: json["category"] ?? "",
        expenseDate: json["expense_date"] ?? "",
        amount: json["amount"] ?? "",
        history: json["history"] == null
            ? []
            : List<History>.from(
                json["history"].map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "expense_date": expenseDate,
        "amount": amount,
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
      };
}

class History {
  String logData;
  String createdAt;
  String createdTime;
  String staffName;

  History({
    required this.logData,
    required this.createdAt,
    required this.createdTime,
    required this.staffName,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        logData: json["log_data"] ?? "",
        createdAt: json["created_at"] ?? "",
        createdTime: json["created_time"] ?? "",
        staffName: json["staff_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "log_data": logData,
        "created_at": createdAt,
        "staff_name": staffName,
      };
}
