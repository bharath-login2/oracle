// To parse this JSON data, do
//
//     final productCategoriesModel = productCategoriesModelFromJson(jsonString);

import 'dart:convert';

ProductCategoriesModel productCategoriesModelFromJson(String str) => ProductCategoriesModel.fromJson(json.decode(str));

String productCategoriesModelToJson(ProductCategoriesModel data) => json.encode(data.toJson());

class ProductCategoriesModel {
    List<Datum> data;
    bool status;
    String message;

    ProductCategoriesModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ProductCategoriesModel.fromJson(Map<String, dynamic> json) => ProductCategoriesModel(
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
    String categoryName;

    Datum({
        required this.id,
        required this.categoryName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        categoryName: json["category_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category_name": categoryName,
    };
}
