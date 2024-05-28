// To parse this JSON data, do
//
//     final productListModel = productListModelFromJson(jsonString);

import 'dart:convert';

ProductListModel productListModelFromJson(String str) => ProductListModel.fromJson(json.decode(str));

String productListModelToJson(ProductListModel data) => json.encode(data.toJson());

class ProductListModel {
    List<Datum> data;
    bool status;
    String message;

    ProductListModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ProductListModel.fromJson(Map<String, dynamic> json) => ProductListModel(
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
    String productName;
    String totalAmount;
    String productImage;
    String categoryName;
    String subCategory;
    String productMrp;
    String contentId;

    Datum({
        required this.id,
        required this.productName,
        required this.totalAmount,
        required this.productImage,
        required this.categoryName,
        required this.subCategory,
        required this.productMrp,
        required this.contentId,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        productName: json["product_name"],
        totalAmount: json["total_amount"],
        productImage: json["product_image"],
        categoryName: json["category_name"],
        subCategory: json["sub_category"],
        productMrp: json["product_mrp"],
        contentId: json["content_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "total_amount": totalAmount,
        "product_image": productImage,
        "category_name": categoryName,
        "sub_category": subCategory,
        "product_mrp": productMrp,
        "content_id": contentId,
    };
}
