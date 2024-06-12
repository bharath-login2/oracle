// To parse this JSON data, do
//
//     final viewLeadsModel = viewLeadsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ViewLeadsModel viewLeadsModelFromJson(String str) => ViewLeadsModel.fromJson(json.decode(str));

String viewLeadsModelToJson(ViewLeadsModel data) => json.encode(data.toJson());

class ViewLeadsModel {
    Data data;
    bool status;
    String message;

    ViewLeadsModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ViewLeadsModel.fromJson(Map<String, dynamic> json) => ViewLeadsModel(
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
    String fromdate;
    String todate;
    bool callPermission;
    String warningMessage;
    String callLeadId;

    Data({
        required this.details,
        required this.totalLeads,
        required this.fromdate,
        required this.todate,
        required this.callPermission,
        required this.warningMessage,
        required this.callLeadId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        details:json["details"]==null?[]: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
        totalLeads: json["totalLeads"]??0,
        fromdate: json["fromdate"]??"",
        todate: json["todate"]??"",
        callPermission: json["callPermission"],
        warningMessage: json["warningMessage"]??"",
        callLeadId: json["callLeadId"]??"",
    );

    Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "totalLeads": totalLeads,
        "fromdate": fromdate,
        "todate": todate,
        "callPermission": callPermission,
        "warningMessage": warningMessage,
        "callLeadId": callLeadId,
    };
}

class Detail {
    String callDetailsId;
    String callMasterId;
    String calledDate;
    String createdDate;
    String lastCalledDate;
    int callResultId;
    String callStatusId;
    bool isNewCall;
    String followupDate;
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
    bool isSelected;

    Detail({
        required this.callDetailsId,
        required this.callMasterId,
        required this.calledDate,
        required this.createdDate,
        required this.lastCalledDate,
        required this.callResultId,
        required this.callStatusId,
        required this.isNewCall,
        required this.followupDate,
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
        required this.isSelected,
    });

    factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        callDetailsId: json["call_details_id"]??"",
        callMasterId: json["call_master_id"]??"",
        calledDate: json["called_date"]??"",
        createdDate: json["created_date"]??"",
        lastCalledDate: json["last_called_date"]??"",
        callResultId: json["call_result_id"]??0,
        callStatusId: json["call_status_id"]??"",
        isNewCall: json["is_new_call"]??false,
        followupDate: json["followup_date"]??"",
        scheduledDate: json["scheduled_date"]??"",
        clientName: json["client_name"]??"",
        contactNumber1: json["contact_number1"]??"",
        callResult: json["call_result"]??"",
        proPicThumb: json["pro_pic_thumb"]??"",
        staffName: json["staff_name"]??"",
        leadCategory: json["lead_category"]??"",
        priority: json["priority"]??"",
        priorityName: json["priority_name"]??"",
        categoryCount: json["category_count"]??"",
        leadCategoryId: json["lead_category_id"]??"",
        leadSubCategoryId: json["lead_sub_category_id"]??"",
        cost: json["cost"]??"",
        address: json["address"]??"",
        leadSubCategory: json["lead_sub_category"]??"",
        profilePic: json["profile_pic"]??"",
        isCalled: json["is_called"],
        isSelected: json["is_selected"],
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
        "category_count": categoryCount,
        "lead_category_id": leadCategoryId,
        "lead_sub_category_id": leadSubCategoryId,
        "cost": cost,
        "address": address,
        "lead_sub_category": leadSubCategory,
        "profile_pic": profilePic,
        "is_called": isCalled,
        "is_selected": isSelected,
    };
}
