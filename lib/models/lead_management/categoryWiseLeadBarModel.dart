import 'dart:convert';

CategoryWiseLeadBarModel categoryWiseLeadBarModelFromJson(String str) =>
    CategoryWiseLeadBarModel.fromJson(json.decode(str));

String categoryWiseLeadBarModelToJson(CategoryWiseLeadBarModel data) =>
    json.encode(data.toJson());

class CategoryWiseLeadBarModel {
  final Data? data;
  final bool? status;
  final String? message;

  CategoryWiseLeadBarModel({
    this.data,
    this.status,
    this.message,
  });

  factory CategoryWiseLeadBarModel.fromJson(Map<String, dynamic> json) =>
      CategoryWiseLeadBarModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  final List<CategoryLead>? categoryLeads;
  final int? categoryTotal;

  Data({
    this.categoryLeads,
    this.categoryTotal,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        categoryLeads: json["category_leads"] == null
            ? []
            : List<CategoryLead>.from(
                json["category_leads"]!.map((x) => CategoryLead.fromJson(x))),
        categoryTotal: json["category_total"],
      );

  Map<String, dynamic> toJson() => {
        "category_leads": categoryLeads == null
            ? []
            : List<dynamic>.from(categoryLeads!.map((x) => x.toJson())),
        "category_total": categoryTotal,
      };
}

class CategoryLead {
  final String? categoryName;
  final String? categoryId;
  final String? categoryCount;
  final String? categoryPercentage;

  CategoryLead({
    this.categoryName,
    this.categoryId,
    this.categoryCount,
    this.categoryPercentage,
  });

  factory CategoryLead.fromJson(Map<String, dynamic> json) => CategoryLead(
        categoryName: json["categoryName"],
        categoryId: json["categoryId"],
        categoryCount: json["categoryCount"],
        categoryPercentage: json["categoryPercentage"],
      );

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "categoryId": categoryId,
        "categoryCount": categoryCount,
        "categoryPercentage": categoryPercentage,
      };
}
