import 'dart:convert';
AccountHeadModel accountHeadModelFromJson(String str) => AccountHeadModel.fromJson(json.decode(str));
String accountHeadModelToJson(AccountHeadModel data) => json.encode(data.toJson());
class AccountHeadModel {
    Data data;
    bool status;
    String message;
    AccountHeadModel({
        required this.data,
        required this.status,
        required this.message,
    });
    factory AccountHeadModel.fromJson(Map<String, dynamic> json) => AccountHeadModel(
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
    bool isReadAccHead;
    Data({
        required this.lists,
        required this.isReadAccHead,
    });
    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        isReadAccHead: json["is_read_acc_head"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "is_read_acc_head": isReadAccHead,
    };
}

class ListElement {
    String accountId;
    String accountName;
    String pendingAmount;

    ListElement({
        required this.accountId,
        required this.accountName,
        required this.pendingAmount,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        accountId: json["account_id"],
        accountName: json["account_name"],
        pendingAmount: json["pending_amount"],
    );

    Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
        "pending_amount": pendingAmount,
    };
}
