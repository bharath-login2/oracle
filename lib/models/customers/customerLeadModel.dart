import 'dart:convert';

class GetCustomerLeadsModel {
  bool? status;
  String? message;
  List<CustomerLeadData>? data;

  GetCustomerLeadsModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetCustomerLeadsModel.fromJson(Map<String, dynamic> json) => GetCustomerLeadsModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<CustomerLeadData>.from(json["data"]!.map((x) => CustomerLeadData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CustomerLeadData {
  String? callDetailsId;
  String? callMasterId;
  String? calledDate;
  String? createdDate;
  String? lastCalledDate;
  int? callResultId;
  String? callStatusId;
  bool? isNewCall;
  String? followupDate;
  String? scheduledDate;
  String? clientName;
  String? contactNumber1;
  String? callResult;
  String? proPicThumb;
  String? staffName;
  String? leadCategory;
  String? priority;
  String? priorityName;
  String? categoryCount;
  String? leadCategoryId;
  String? leadSubCategoryId;
  String? cost;
  String? address;
  String? leadSubCategory;
  String? custId;
  String? profilePic;
  bool? isCalled;
  bool? isSelected;
  bool? isCustomer;

  CustomerLeadData({
    this.callDetailsId,
    this.callMasterId,
    this.calledDate,
    this.createdDate,
    this.lastCalledDate,
    this.callResultId,
    this.callStatusId,
    this.isNewCall,
    this.followupDate,
    this.scheduledDate,
    this.clientName,
    this.contactNumber1,
    this.callResult,
    this.proPicThumb,
    this.staffName,
    this.leadCategory,
    this.priority,
    this.priorityName,
    this.categoryCount,
    this.leadCategoryId,
    this.leadSubCategoryId,
    this.cost,
    this.address,
    this.leadSubCategory,
    this.custId,
    this.profilePic,
    this.isCalled,
    this.isSelected,
    this.isCustomer,
  });

  factory CustomerLeadData.fromJson(Map<String, dynamic> json) => CustomerLeadData(
    callDetailsId: json["call_details_id"],
    callMasterId: json["call_master_id"],
    calledDate: json["called_date"],
    createdDate: json["created_date"],
    lastCalledDate: json["last_called_date"],
    callResultId: json["call_result_id"],
    callStatusId: json["call_status_id"],
    isNewCall: json["is_new_call"],
    followupDate: json["followup_date"],
    scheduledDate: json["scheduled_date"],
    clientName: json["client_name"],
    contactNumber1: json["contact_number1"],
    callResult: json["call_result"],
    proPicThumb: json["pro_pic_thumb"],
    staffName: json["staff_name"],
    leadCategory: json["lead_category"],
    priority: json["priority"],
    priorityName: json["priority_name"],
    categoryCount: json["category_count"],
    leadCategoryId: json["lead_category_id"],
    leadSubCategoryId: json["lead_sub_category_id"],
    cost: json["cost"],
    address: json["address"],
    leadSubCategory: json["lead_sub_category"],
    custId: json["cust_id"],
    profilePic: json["profile_pic"],
    isCalled: json["is_called"],
    isSelected: json["is_selected"],
    isCustomer: json["is_customer"],
  );

  Map<String, dynamic> toJson() => {
    "call_details_id": callDetailsId,
    "call_master_id": callMasterId,
    "called_date": calledDate,
    "created_date": createdDate,
    "last_called_date": lastCalledDate,
    "call_result_id": callResultId,
    "call_status_id": callStatusId,
    "is_new_call": isNewCall,
    "followup_date": followupDate,
    "scheduled_date": scheduledDate,
    "client_name": clientName,
    "contact_number1": contactNumber1,
    "call_result": callResult,
    "pro_pic_thumb": proPicThumb,
    "staff_name": staffName,
    "lead_category": leadCategory,
    "priority": priority,
    "priority_name": priorityName,
    "category_count": categoryCount,
    "lead_category_id": leadCategoryId,
    "lead_sub_category_id": leadSubCategoryId,
    "cost": cost,
    "address": address,
    "lead_sub_category": leadSubCategory,
    "cust_id": custId,
    "profile_pic": profilePic,
    "is_called": isCalled,
    "is_selected": isSelected,
    "is_customer": isCustomer,
  };
}

GetCustomerLeadsModel getCustomerLeadsModelFromJson(String str) => GetCustomerLeadsModel.fromJson(json.decode(str));

String getCustomerLeadsModelToJson(GetCustomerLeadsModel data) => json.encode(data.toJson());