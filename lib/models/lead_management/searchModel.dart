// To parse this JSON data, do
//
//     final searchModel = searchModelFromJson(jsonString);

import 'dart:convert';

SearchModel searchModelFromJson(String str) => SearchModel.fromJson(json.decode(str));

String searchModelToJson(SearchModel data) => json.encode(data.toJson());

class SearchModel {
    Data data;
    bool status;
    String message;

    SearchModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
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
    List<Detail> details;
    int totalLeads;
    bool callPermission;
    String warningMessage;
    String callLeadId;

    Data({
        required this.details,
        required this.totalLeads,
        required this.callPermission,
        required this.warningMessage,
        required this.callLeadId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
        totalLeads: json["totalLeads"],
        callPermission: json["callPermission"],
        warningMessage: json["warningMessage"],
        callLeadId: json["callLeadId"],
    );

    Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "totalLeads": totalLeads,
        "callPermission": callPermission,
        "warningMessage": warningMessage,
        "callLeadId": callLeadId,
    };
}

class Detail {
    String callMasterId;
    String calledDate;
    int callResultId;
    String callStatusId;
    String scheduledDate;
    String clientName;
    String contactNumber1;
    String callResult;
    String proPicThumb;
    String staffName;
    String leadCategory;
    String priority;
    String priorityName;
    String categoryCount;
    String leadCategoryId;
    String leadSubCategoryId;
    String cost;
    String address;
    String leadSubCategory;
    String profilePic;
    bool isCalled;

    Detail({
        required this.callMasterId,
        required this.calledDate,
        required this.callResultId,
        required this.callStatusId,
        required this.scheduledDate,
        required this.clientName,
        required this.contactNumber1,
        required this.callResult,
        required this.proPicThumb,
        required this.staffName,
        required this.leadCategory,
        required this.priority,
        required this.priorityName,
        required this.categoryCount,
        required this.leadCategoryId,
        required this.leadSubCategoryId,
        required this.cost,
        required this.address,
        required this.leadSubCategory,
        required this.profilePic,
        required this.isCalled,
    });

    factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        callMasterId: json["call_master_id"],
        calledDate: json["called_date"],
        callResultId: json["call_result_id"],
        callStatusId: json["call_status_id"],
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
        profilePic: json["profile_pic"],
        isCalled: json["is_called"],
    );

    Map<String, dynamic> toJson() => {
        "call_master_id": callMasterId,
        "called_date": calledDate,
        "call_result_id": callResultId,
        "call_status_id": callStatusId,
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
        "profile_pic": profilePic,
        "is_called": isCalled,
    };
}
