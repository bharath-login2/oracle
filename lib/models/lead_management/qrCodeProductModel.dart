class QrCodeProductResponse {
  bool? status;
  String? message;
  QrCodeProductData? data;

  QrCodeProductResponse({
    this.status,
    this.message,
    this.data,
  });

  QrCodeProductResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? QrCodeProductData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class QrCodeProductData {
  String? id;
  String? productName;
  String? barCode;
  String? contentId;
  String? categoryName;
  String? categoryId;
  String? subCategoryId;
  String? subCategory;
  String? productCode;
  String? productMrp;
  String? sellingPrice;
  String? discountPercent;
  String? discountAmount;
  String? taxPercent;
  String? totalAmount;
  String? purchaseAmount;
  String? description;
  String? productImage;
  String? productType;
  String? brand;
  String? checkStock;
  String? openingStock;
  String? currentStock;
  String? stockStatus;
  String? isFeatureProduct;
  String? isGst;
  String? unitId;
  String? unitName;
  String? publishStatus;
  String? visibility;
  String? rentalPrice;
  String? warranty;
  String? expiryDate;
  String? warrantyNo;
  List<String>? pipelineName;
  String? serviceCycle;
  String? freeCount;
  String? paidCount;
  String? serviceNoDays;
  String? serviceWeeks;
  String? serviceMonthDays;
  String? serviceYearDays;
  String? serviceYearMonth;
  List<String>? complaintType;

  QrCodeProductData({
    this.id,
    this.productName,
    this.barCode,
    this.contentId,
    this.categoryName,
    this.categoryId,
    this.subCategoryId,
    this.subCategory,
    this.productCode,
    this.productMrp,
    this.sellingPrice,
    this.discountPercent,
    this.discountAmount,
    this.taxPercent,
    this.totalAmount,
    this.purchaseAmount,
    this.description,
    this.productImage,
    this.productType,
    this.brand,
    this.checkStock,
    this.openingStock,
    this.currentStock,
    this.stockStatus,
    this.isFeatureProduct,
    this.isGst,
    this.unitId,
    this.unitName,
    this.publishStatus,
    this.visibility,
    this.rentalPrice,
    this.warranty,
    this.expiryDate,
    this.warrantyNo,
    this.pipelineName,
    this.serviceCycle,
    this.freeCount,
    this.paidCount,
    this.serviceNoDays,
    this.serviceWeeks,
    this.serviceMonthDays,
    this.serviceYearDays,
    this.serviceYearMonth,
    this.complaintType,
  });

  QrCodeProductData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    productName = json['product_name'];
    barCode = json['bar_code'];
    contentId = json['content_id'];
    categoryName = json['category_name'];
    categoryId = json['category_id']?.toString();
    subCategoryId = json['sub_category_id']?.toString();
    subCategory = json['sub_category'];
    productCode = json['product_code'];
    productMrp = json['product_mrp'];
    sellingPrice = json['selling_price'];
    discountPercent = json['discount_percent'];
    discountAmount = json['discount_amount'];
    taxPercent = json['tax_percent'];
    totalAmount = json['total_amount'];
    purchaseAmount = json['purchase_amount'];
    description = json['description'];
    productImage = json['product_image'];
    productType = json['product_type'];
    brand = json['brand'];
    checkStock = json['check_stock']?.toString();
    openingStock = json['opening_stock']?.toString();
    currentStock = json['current_stock']?.toString();
    stockStatus = json['stock_status'];
    isFeatureProduct = json['is_feature_product'];
    isGst = json['is_gst'];
    unitId = json['unit_id']?.toString();
    unitName = json['unit_name'];
    publishStatus = json['publish_status'];
    visibility = json['visibility'];
    rentalPrice = json['rental_price'];
    warranty = json['warranty'];
    expiryDate = json['expiry_date'];
    warrantyNo = json['warranty_no'];
    pipelineName = json['pipeline_name'] != null 
        ? List<String>.from(json['pipeline_name']) 
        : null;
    serviceCycle = json['service_cycle'];
    freeCount = json['free_count']?.toString();
    paidCount = json['paid_count']?.toString();
    serviceNoDays = json['service_no_days']?.toString();
    serviceWeeks = json['service_weeks'];
    serviceMonthDays = json['service_month_days']?.toString();
    serviceYearDays = json['service_year_days']?.toString();
    serviceYearMonth = json['service_year_month'];
    complaintType = json['complaint_type'] != null 
        ? List<String>.from(json['complaint_type']) 
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['product_name'] = productName;
    data['bar_code'] = barCode;
    data['content_id'] = contentId;
    data['category_name'] = categoryName;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['sub_category'] = subCategory;
    data['product_code'] = productCode;
    data['product_mrp'] = productMrp;
    data['selling_price'] = sellingPrice;
    data['discount_percent'] = discountPercent;
    data['discount_amount'] = discountAmount;
    data['tax_percent'] = taxPercent;
    data['total_amount'] = totalAmount;
    data['purchase_amount'] = purchaseAmount;
    data['description'] = description;
    data['product_image'] = productImage;
    data['product_type'] = productType;
    data['brand'] = brand;
    data['check_stock'] = checkStock;
    data['opening_stock'] = openingStock;
    data['current_stock'] = currentStock;
    data['stock_status'] = stockStatus;
    data['is_feature_product'] = isFeatureProduct;
    data['is_gst'] = isGst;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['publish_status'] = publishStatus;
    data['visibility'] = visibility;
    data['rental_price'] = rentalPrice;
    data['warranty'] = warranty;
    data['expiry_date'] = expiryDate;
    data['warranty_no'] = warrantyNo;
    data['pipeline_name'] = pipelineName;
    data['service_cycle'] = serviceCycle;
    data['free_count'] = freeCount;
    data['paid_count'] = paidCount;
    data['service_no_days'] = serviceNoDays;
    data['service_weeks'] = serviceWeeks;
    data['service_month_days'] = serviceMonthDays;
    data['service_year_days'] = serviceYearDays;
    data['service_year_month'] = serviceYearMonth;
    data['complaint_type'] = complaintType;
    return data;
  }
}