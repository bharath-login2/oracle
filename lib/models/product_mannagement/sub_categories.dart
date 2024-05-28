// To parse this JSON data, do
//
//     final subCategoriesModel = subCategoriesModelFromJson(jsonString);

import 'dart:convert';

SubCategoriesModel subCategoriesModelFromJson(String str) => SubCategoriesModel.fromJson(json.decode(str));

String subCategoriesModelToJson(SubCategoriesModel data) => json.encode(data.toJson());

class SubCategoriesModel {
    List<Datum> data;
    bool status;
    String message;

    SubCategoriesModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory SubCategoriesModel.fromJson(Map<String, dynamic> json) => SubCategoriesModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
    };
}

class Datum {
    String id;
    String categoryId;
    String subCategory;

    Datum({
        required this.id,
        required this.categoryId,
        required this.subCategory,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        categoryId: json["category_id"],
        subCategory: json["sub_category"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "sub_category": subCategory,
    };
}
