import 'dart:convert';

ProdectsByIdModel prodectsByIdModelFromJson(String str) =>
    ProdectsByIdModel.fromJson(json.decode(str));
String prodectsByIdModelToJson(ProdectsByIdModel data) =>
    json.encode(data.toJson());

class ProdectsByIdModel {
  Data data;
  bool status;
  String message;

  ProdectsByIdModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory ProdectsByIdModel.fromJson(Map<String, dynamic> json) =>
      ProdectsByIdModel(
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
  String purchasePrice;
 // String barcode;
  String taxPercent;
  String totalAmount;
  String noOfDays;
  String remindBefore;
  String description;
  String productImage;
  String productType;
  String brand;
  String discountPercent;
    String discountAmount;
  String checkStock;
  String openingStock;
  String currentStock;
  String stockStatus;
  String isFeatureProduct;
  String isGst;
  String unitId;
  String unitName;
  String publishStatus;
  String visibility;
  String rentalPrice;
  String warranty;
  String expiryDate;
  String warrantyNo;
   String purchaseAmount;
    String barCode;
  List<String> pipelineName;
  String serviceCycle;
  String freeCount;
  String paidCount;
  String serviceNoDays;
  String serviceWeeks;
  String serviceMonthDays;
  String serviceYearDays;
  String serviceYearMonth;
  List<ComplaintType> complaintType;
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
    required this.purchasePrice,
    // //required this.barcode,
    required this.taxPercent,
    required this.totalAmount,
    required this.noOfDays,
    required this.remindBefore,
    required this.description,
    required this.productImage,
    required this.productType,
    required this.brand,
    required this.discountPercent,
    required this.discountAmount,
    required this.checkStock,
    required this.openingStock,
    required this.currentStock,
    required this.stockStatus,
    required this.isFeatureProduct,
    required this.isGst,
    required this.unitId,
    required this.unitName,
    required this.publishStatus,
    required this.visibility,
    required this.rentalPrice,
    required this.warranty,
    required this.expiryDate,
    required this.warrantyNo,
      required this.purchaseAmount,
    required this.barCode,
    required this.pipelineName,
    required this.serviceCycle,
    required this.freeCount,
    required this.paidCount,
    required this.serviceNoDays,
    required this.serviceWeeks,
    required this.serviceMonthDays,
    required this.serviceYearDays,
    required this.serviceYearMonth,
    required this.complaintType,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? "",
        productName: json["product_name"] ?? "",
        contentId: json["content_id"] ?? "",
        categoryName: json["category_name"] ?? "",
        categoryId: json["category_id"] ?? "",
        subCategoryId: json["sub_category_id"] ?? "",
        subCategory: json["sub_category"] ?? "",
        productCode: json["product_code"] ?? "",
        productMrp: json["product_mrp"] ?? "",
        sellingPrice: json["selling_price"] ?? "",
        purchasePrice: json["purchase_price"] ?? "",
        // barcode: json["barcode"] ?? "",
        taxPercent: json["tax_percent"] ?? "",
        totalAmount: json["total_amount"] ?? "",
        noOfDays: json["no_of_days"] ?? "",
        remindBefore: json["remind_before"] ?? "",
        description: json["description"] ?? "",
        productImage: json["product_image"] ?? "",
        productType: json["product_type"] ?? "",
        brand: json["brand"] ?? "",
        discountPercent: json["discount_percent"] ?? "",
        discountAmount: json["discount_amount"] ?? "",
        checkStock: json["check_stock"] ?? "",
        openingStock: json["opening_stock"] ?? "",
        currentStock: json["current_stock"] ?? "",
        stockStatus: json["stock_status"] ?? "",
        isFeatureProduct: json["is_feature_product"] ?? "",
        isGst: json["is_gst"] ?? "",
        unitId: json["unit_id"] ?? "",
        unitName: json["unit_name"] ?? "",
        publishStatus: json["publish_status"] ?? "",
        visibility: json["visibility"] ?? "",
        rentalPrice: json["rental_price"] ?? "",
        warranty: json["warranty"] ?? "",
        expiryDate: json["expiry_date"] ?? "",
        warrantyNo: json["warranty_no"] ?? "",
        purchaseAmount: json["purchase_amount"] ?? "",
        barCode: json["bar_code"] ?? "",
        pipelineName: List<String>.from(
            json["pipeline_name"]?.map((x) => x.toString()) ?? []),
        serviceCycle: json["service_cycle"] ?? "",
        freeCount: json["free_count"] ?? "",
        paidCount: json["paid_count"] ?? "",
        serviceNoDays: json["service_no_days"] ?? "",
        serviceWeeks: json["service_weeks"] ?? "",
        serviceMonthDays: json["service_month_days"] ?? "",
        serviceYearDays: json["service_year_days"] ?? "",
        serviceYearMonth: json["service_year_month"] ?? "",
        complaintType: json["complaint_type"] != null
            ? List<ComplaintType>.from(
                json["complaint_type"].map((x) => ComplaintType.fromJson(x)))
            : [],
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
        "purchase_price": purchasePrice,
     //   "barcode": barcode,
        "tax_percent": taxPercent,
        "total_amount": totalAmount,
        "no_of_days": noOfDays,
        "remind_before": remindBefore,
        "description": description,
        "product_image": productImage,
        "product_type": productType,
        "brand": brand,
        "discount_percent": discountPercent,
        "discount_amount": discountAmount,
        "check_stock": checkStock,
        "opening_stock": openingStock,
        "current_stock": currentStock,
        "stock_status": stockStatus,
        "is_feature_product": isFeatureProduct,
        "is_gst": isGst,
        "unit_id": unitId,
        "unit_name": unitName,
        "publish_status": publishStatus,
        "visibility": visibility,
        "rental_price": rentalPrice,
        "warranty": warranty,
        "expiry_date": expiryDate,
        "warranty_no": warrantyNo,
        "purchase_amount": purchaseAmount,
        "bar_code": barCode,
        "pipeline_name": List<dynamic>.from(pipelineName.map((x) => x)),
        "service_cycle": serviceCycle,
        "free_count": freeCount,
        "paid_count": paidCount,
        "service_no_days": serviceNoDays,
        "service_weeks": serviceWeeks,
        "service_month_days": serviceMonthDays,
        "service_year_days": serviceYearDays,
        "service_year_month": serviceYearMonth,
        "complaint_type":
            List<dynamic>.from(complaintType.map((x) => x.toJson())),
      };
}

class ComplaintType {
  String type;
  String remark;

  ComplaintType({
    required this.type,
    required this.remark,
  });

  factory ComplaintType.fromJson(Map<String, dynamic> json) => ComplaintType(
        type: json["type"] ?? "",
        remark: json["remark"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "remark": remark,
      };
}
