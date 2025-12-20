class QuotationDetailsModel {
  final String? status;
  final QuotationData? data;

  QuotationDetailsModel({
    this.status,
    this.data,
  });

  factory QuotationDetailsModel.fromJson(Map<String, dynamic> json) {
    return QuotationDetailsModel(
      status: json['status'],
      data: json['data'] != null ? QuotationData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class QuotationData {
  final List<QuotationDatum>? quotationData;
  final List<ItemDatum>? itemData;
  final List<QuotationPackageEst>? quotationPackageEst;

  QuotationData({
    this.quotationData,
    this.itemData,
    this.quotationPackageEst,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    return QuotationData(
      quotationData: json['quotationData'] != null
          ? List<QuotationDatum>.from(
              json['quotationData'].map((x) => QuotationDatum.fromJson(x)))
          : [],
      itemData: json['ItemData'] != null
          ? List<ItemDatum>.from(
              json['ItemData'].map((x) => ItemDatum.fromJson(x)))
          : [],
      quotationPackageEst: json['quotationPackageEst'] != null
          ? List<QuotationPackageEst>.from(
              json['quotationPackageEst']
                  .map((x) => QuotationPackageEst.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotationData': quotationData?.map((x) => x.toJson()).toList(),
      'ItemData': itemData?.map((x) => x.toJson()).toList(),
      'quotationPackageEst':
          quotationPackageEst?.map((x) => x.toJson()).toList(),
    };
  }
}

class QuotationDatum {
  final String? id;
  final String? quoteId;
  final String? customerId;
  final String? workorderId;
  final String? enquiryDate;
  final String? totalAmount;
  final String? quotationType;
  final String? approvalStatus;
  final String? createdBy;
  final String? address;
  final String? district;
  final String? state;
  final String? nationality;
  final String? templateId;
  final String? companyId;
  final String? remarks;
  final String? createdAt;
  final String? status;
  final String? qtePk;
  final String? userName;
  final String? customerName;
  final String? templateName;
  final String? fieldId;

  QuotationDatum({
    this.id,
    this.quoteId,
    this.customerId,
    this.workorderId,
    this.enquiryDate,
    this.totalAmount,
    this.quotationType,
    this.approvalStatus,
    this.createdBy,
    this.address,
    this.district,
    this.state,
    this.nationality,
    this.templateId,
    this.companyId,
    this.remarks,
    this.createdAt,
    this.status,
    this.qtePk,
    this.userName,
    this.customerName,
    this.templateName,
    this.fieldId,
  });

  factory QuotationDatum.fromJson(Map<String, dynamic> json) {
    return QuotationDatum(
      id: json['id'],
      quoteId: json['quote_id'],
      customerId: json['customer_id'],
      workorderId: json['workorder_id'],
      enquiryDate: json['enquiry_date'],
      totalAmount: json['total_amount'],
      quotationType: json['quotation_type'],
      approvalStatus: json['approval_status'],
      createdBy: json['created_by'],
      address: json['address'],
      district: json['district'],
      state: json['state'],
      nationality: json['nationality'],
      templateId: json['template_id'],
      companyId: json['company_id'],
      remarks: json['remarks'],
      createdAt: json['created_at'],
      status: json['status'],
      qtePk: json['qte_pk'],
      userName: json['user_name'],
      customerName: json['customer_name'],
      templateName: json['template_name'],
      fieldId: json['field_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote_id': quoteId,
      'customer_id': customerId,
      'workorder_id': workorderId,
      'enquiry_date': enquiryDate,
      'total_amount': totalAmount,
      'quotation_type': quotationType,
      'approval_status': approvalStatus,
      'created_by': createdBy,
      'address': address,
      'district': district,
      'state': state,
      'nationality': nationality,
      'template_id': templateId,
      'company_id': companyId,
      'remarks': remarks,
      'created_at': createdAt,
      'status': status,
      'qte_pk': qtePk,
      'user_name': userName,
      'customer_name': customerName,
      'template_name': templateName,
      'field_id': fieldId,
    };
  }
}

class ItemDatum {
  final String? id;
  final String? quoteId;
  final String? item;
  final String? quantity;
  final String? unitPrice;
  final String? total;
  final String? unit;
  final String? gst;
  final String? subTotal;
  final String? status;
  final String? productName;

  ItemDatum({
    this.id,
    this.quoteId,
    this.item,
    this.quantity,
    this.unitPrice,
    this.total,
    this.unit,
    this.gst,
    this.subTotal,
    this.status,
    this.productName,
  });

  factory ItemDatum.fromJson(Map<String, dynamic> json) {
    return ItemDatum(
      id: json['id'],
      quoteId: json['quote_id'],
      item: json['item'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
      total: json['total'],
      unit: json['unit'],
      gst: json['gst'],
      subTotal: json['sub_total'],
      status: json['status'],
      productName: json['product_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote_id': quoteId,
      'item': item,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
      'unit': unit,
      'gst': gst,
      'sub_total': subTotal,
      'status': status,
      'product_name': productName,
    };
  }
}

class QuotationPackageEst {
  final String? id;
  final String? templateId;
  final String? quotePk;
  final String? fieldId;
  final String? fieldValue;
  final String? companyId;
  final String? isDeleted;
  final String? createdAt;
  final String? updatedAt;

  QuotationPackageEst({
    this.id,
    this.templateId,
    this.quotePk,
    this.fieldId,
    this.fieldValue,
    this.companyId,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory QuotationPackageEst.fromJson(Map<String, dynamic> json) {
    return QuotationPackageEst(
      id: json['id'],
      templateId: json['template_id'],
      quotePk: json['quote_pk'],
      fieldId: json['field_id'],
      fieldValue: json['field_value'],
      companyId: json['company_id'],
      isDeleted: json['isDeleted'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_id': templateId,
      'quote_pk': quotePk,
      'field_id': fieldId,
      'field_value': fieldValue,
      'company_id': companyId,
      'isDeleted': isDeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
