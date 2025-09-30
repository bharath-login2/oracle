import 'dart:convert';

class PendingList {
    bool status;
    String message;
    Data data;

    PendingList({
        required this.status,
        required this.message,
        required this.data,
    });

    factory PendingList.fromRawJson(String str) => PendingList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PendingList.fromJson(Map<String, dynamic> json) => PendingList(
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
    List<PendingListElement> pendingList;

    Data({
        required this.pendingList,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        pendingList: List<PendingListElement>.from(json["pending_list"].map((x) => PendingListElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "pending_list": List<dynamic>.from(pendingList.map((x) => x.toJson())),
    };
}

class PendingListElement {
    String id;
    String accountName;
      String accountNameId;
    String expenseType;
     String expenseTypeId;
    String amount;
    String createdBy;
    String expenseDate;

    PendingListElement({
        required this.id,
        required this.accountName,
          required this.accountNameId,
        required this.expenseType,
         required this.expenseTypeId,
        required this.amount,
        required this.createdBy,
        required this.expenseDate,
    });

    factory PendingListElement.fromRawJson(String str) => PendingListElement.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PendingListElement.fromJson(Map<String, dynamic> json) => PendingListElement(
        id: json["id"]??"",
        accountName: json["account_name"]??"",
         accountNameId: json["account_id"]??"",
        expenseType: json["expense_type"]??"",
         expenseTypeId: json["ExpCatId"]??"",
        amount: json["amount"]??"",
        createdBy: json["created_by"]??"",
        expenseDate: json["expense_date"]??"",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "account_name": accountName,
          "account_id": accountNameId,
        "expense_type": expenseType,
         "ExpCatId": expenseTypeId,
        "amount": amount,
        "created_by": createdBy,
        "expense_date": expenseDate,
    };
}
