// To parse this JSON data, do
//
//     final expenseCategoryList = expenseCategoryListFromJson(jsonString);

import 'dart:convert';

ExpenseCategoryList expenseCategoryListFromJson(String str) => ExpenseCategoryList.fromJson(json.decode(str));

String expenseCategoryListToJson(ExpenseCategoryList data) => json.encode(data.toJson());

class ExpenseCategoryList {
    bool status;
    String message;
    List<ExpCategory> data;

    ExpenseCategoryList({
        required this.status,
        required this.message,
        required this.data,
    });

    factory ExpenseCategoryList.fromJson(Map<String, dynamic> json) => ExpenseCategoryList(
        status: json["status"],
        message: json["message"],
        data: List<ExpCategory>.from(json["data"].map((x) => ExpCategory.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class ExpCategory {
    int typeId;
    String typeName;

    ExpCategory({
        required this.typeId,
        required this.typeName,
    });

    factory ExpCategory.fromJson(Map<String, dynamic> json) => ExpCategory(
        typeId: json["type_id"],
        typeName: json["type_name"],
    );

    Map<String, dynamic> toJson() => {
        "type_id": typeId,
        "type_name": typeName,
    };
}
