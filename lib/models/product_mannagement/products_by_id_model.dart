// To parse this JSON data, do
//
//     final prodectsByIdModel = prodectsByIdModelFromJson(jsonString);

import 'dart:convert';

ProdectsByIdModel prodectsByIdModelFromJson(String str) => ProdectsByIdModel.fromJson(json.decode(str));

String prodectsByIdModelToJson(ProdectsByIdModel data) => json.encode(data.toJson());

class ProdectsByIdModel {
    Data data;
    bool status;
    String message;

    ProdectsByIdModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ProdectsByIdModel.fromJson(Map<String, dynamic> json) => ProdectsByIdModel(
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
    String id;
    String productName;
    String contentId;
    String categoryName;
    String categoryId;
    String subCategoryId;
    String subCategory;
    String productCode;
    String productMrp;
    String sellingPrice;
    String taxPercent;
    String totalAmount;
    String noOfDays;
    String remindBefore;
    String description;
    String productImage;

    Data({
        required this.id,
        required this.productName,
        required this.contentId,
        required this.categoryName,
        required this.categoryId,
        required this.subCategoryId,
        required this.subCategory,
        required this.productCode,
        required this.productMrp,
        required this.sellingPrice,
        required this.taxPercent,
        required this.totalAmount,
        required this.noOfDays,
        required this.remindBefore,
        required this.description,
        required this.productImage,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        productName: json["product_name"],
        contentId: json["content_id"],
        categoryName: json["category_name"],
        categoryId: json["category_id"],
        subCategoryId: json["sub_category_id"],
        subCategory: json["sub_category"],
        productCode: json["product_code"],
        productMrp: json["product_mrp"],
        sellingPrice: json["selling_price"],
        taxPercent: json["tax_percent"],
        totalAmount: json["total_amount"],
        noOfDays: json["no_of_days"],
        remindBefore: json["remind_before"],
        description: json["description"],
        productImage: json["product_image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "content_id": contentId,
        "category_name": categoryName,
        "category_id": categoryId,
        "sub_category_id": subCategoryId,
        "sub_category": subCategory,
        "product_code": productCode,
        "product_mrp": productMrp,
        "selling_price": sellingPrice,
        "tax_percent": taxPercent,
        "total_amount": totalAmount,
        "no_of_days": noOfDays,
        "remind_before": remindBefore,
        "description": description,
        "product_image": productImage,
    };
}
