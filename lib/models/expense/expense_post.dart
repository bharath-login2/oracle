// To parse this JSON data, do
//
//     final expensePostModel = expensePostModelFromJson(jsonString);

import 'dart:convert';

ExpensePostModel expensePostModelFromJson(String str) => ExpensePostModel.fromJson(json.decode(str));

String expensePostModelToJson(ExpensePostModel data) => json.encode(data.toJson());

class ExpensePostModel {
    bool status;
    String message;
    bool data;

    ExpensePostModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory ExpensePostModel.fromJson(Map<String, dynamic> json) => ExpensePostModel(
        status: json["status"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
    };
}
