// To parse this JSON data, do
//
//     final expenseMasterData = expenseMasterDataFromJson(jsonString);

import 'dart:convert';

ExpenseMasterData expenseMasterDataFromJson(String str) =>
    ExpenseMasterData.fromJson(json.decode(str));

String expenseMasterDataToJson(ExpenseMasterData data) =>
    json.encode(data.toJson());

class ExpenseMasterData {
  bool status;
  String message;
  Data data;

  ExpenseMasterData({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ExpenseMasterData.fromJson(Map<String, dynamic> json) =>
      ExpenseMasterData(
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
  List<ExpenseType> expenseType;
  List<AccountHead> accountHead;
  List<StaffList> staffList;

  Data({
    required this.expenseType,
    required this.accountHead,
    required this.staffList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        expenseType: List<ExpenseType>.from(
            json["expense_type"].map((x) => ExpenseType.fromJson(x))),
        accountHead: List<AccountHead>.from(
            json["account_head"].map((x) => AccountHead.fromJson(x))),
        staffList: List<StaffList>.from(
            json["staffList"].map((x) => StaffList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "expense_type": List<dynamic>.from(expenseType.map((x) => x.toJson())),
        "account_head": List<dynamic>.from(accountHead.map((x) => x.toJson())),
        "staffList": List<dynamic>.from(staffList.map((x) => x.toJson())),
      };
}

class AccountHead {
  String accountId;
  String accountName;

  AccountHead({
    required this.accountId,
    required this.accountName,
  });

  factory AccountHead.fromJson(Map<String, dynamic> json) => AccountHead(
        accountId: json["account_id"],
        accountName: json["account_name"],
      );

  Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
      };
}

class ExpenseType {
  String expCatId;
  String expCatName;

  ExpenseType({
    required this.expCatId,
    required this.expCatName,
  });

  factory ExpenseType.fromJson(Map<String, dynamic> json) => ExpenseType(
        expCatId: json["ExpCatId"],
        expCatName: json["ExpCatName"],
      );

  Map<String, dynamic> toJson() => {
        "ExpCatId": expCatId,
        "ExpCatName": expCatName,
      };
}

class StaffList {
  String userId;
  String staffName;

  StaffList({
    required this.userId,
    required this.staffName,
  });

  factory StaffList.fromJson(Map<String, dynamic> json) => StaffList(
        userId: json["user_id"],
        staffName: json["staff_name"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
      };
}
