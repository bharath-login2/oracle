// To parse this JSON data, do
//
//     final postRenewDetailsModel = postRenewDetailsModelFromJson(jsonString);

import 'dart:convert';

PostRenewDetailsModel postRenewDetailsModelFromJson(String str) => PostRenewDetailsModel.fromJson(json.decode(str));

String postRenewDetailsModelToJson(PostRenewDetailsModel data) => json.encode(data.toJson());

class PostRenewDetailsModel {
    String message;
    Data data;
    bool status;

    PostRenewDetailsModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory PostRenewDetailsModel.fromJson(Map<String, dynamic> json) => PostRenewDetailsModel(
        message: json["message"],
        data: Data.fromJson(json["data"]),
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
        "status": status,
    };
}

class Data {
    String customerId;
    bool isRedirect;

    Data({
        required this.customerId,
        required this.isRedirect,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        customerId: json["customer_id"],
        isRedirect: json["is_redirect"],
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "is_redirect": isRedirect,
    };
}
