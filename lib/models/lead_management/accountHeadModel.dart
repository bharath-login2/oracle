// To parse this JSON data, do
//
//     final accountHeadDetails = accountHeadDetailsFromJson(jsonString);
import 'dart:convert';

AccountHeadDetails accountHeadDetailsFromJson(String str) => AccountHeadDetails.fromJson(json.decode(str));

String accountHeadDetailsToJson(AccountHeadDetails data) => json.encode(data.toJson());

class AccountHeadDetails {
    bool status;
    String message;
    Data data;

    AccountHeadDetails({
        required this.status,
        required this.message,
        required this.data,
    });

    factory AccountHeadDetails.fromJson(Map<String, dynamic> json) => AccountHeadDetails(
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
    List<AccountHead> accountHead;

    Data({
        required this.accountHead,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        accountHead: List<AccountHead>.from(json["account_head"].map((x) => AccountHead.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "account_head": List<dynamic>.from(accountHead.map((x) => x.toJson())),
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
        accountId: json["account_id"]??"",
        accountName: json["account_name"]??"",
    );

    Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
    };
}
