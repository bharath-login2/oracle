// To parse this JSON data, do
//
//     final addItemModel = addItemModelFromJson(jsonString);

import 'dart:convert';

AddItemModel addItemModelFromJson(String str) => AddItemModel.fromJson(json.decode(str));

String addItemModelToJson(AddItemModel data) => json.encode(data.toJson());

class AddItemModel {
    String message;
    Data data;
    bool status;

    AddItemModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory AddItemModel.fromJson(Map<String, dynamic> json) => AddItemModel(
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
    String id;
    String status;
    String fieldVal;

    Data({
        required this.id,
        required this.status,
        required this.fieldVal,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        status: json["status"],
        fieldVal: json["field_val"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "field_val": fieldVal,
    };
}
