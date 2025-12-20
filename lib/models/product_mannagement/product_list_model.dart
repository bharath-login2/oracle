// To parse this JSON data, do
//
//     final productListModel = productListModelFromJson(jsonString);

import 'dart:convert';

ProductListModel productListModelFromJson(String str) =>
    ProductListModel.fromJson(json.decode(str));

String productListModelToJson(ProductListModel data) =>
    json.encode(data.toJson());

class ProductListModel {
  List<ProductList> data;
  bool status;
  String message;

  ProductListModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) =>
      ProductListModel(
        data: List<ProductList>.from(
            json["data"].map((x) => ProductList.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class ProductList {
  String id;
  String productName;
  String totalAmount;
  String productImage;
  String categoryName;
  String subCategory;
  String productMrp;
  String contentId;
  String taxPercentage;
  String sellingPrice;
  ProductList({
    required this.id,
    required this.productName,
    required this.totalAmount,
    required this.productImage,
    required this.categoryName,
    required this.subCategory,
    required this.productMrp,
    required this.contentId,
    required this.taxPercentage,
    required this.sellingPrice,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
        id: json["id"],
        productName: json["product_name"],
        totalAmount: json["total_amount"],
        productImage: json["product_image"],
        categoryName: json["category_name"],
        subCategory: json["sub_category"],
        productMrp: json["product_mrp"],
        contentId: json["content_id"],
        taxPercentage: json["tax_percent"],
        sellingPrice: json["selling_price"],
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
        "tax_percent": taxPercentage,
        "selling_price": sellingPrice,
      };
}
