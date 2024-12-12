// To parse this JSON data, do
//
//     final viewStaffModel = viewStaffModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ViewStaffModel viewStaffModelFromJson(String str) => ViewStaffModel.fromJson(json.decode(str));

String viewStaffModelToJson(ViewStaffModel data) => json.encode(data.toJson());

class ViewStaffModel {
    Data data;
    bool status;
    String message;

    ViewStaffModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ViewStaffModel.fromJson(Map<String, dynamic> json) => ViewStaffModel(
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
    List<StaffList> staffList;

    Data({
        required this.staffList,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        staffList: List<StaffList>.from(json["staff_list"].map((x) => StaffList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "staff_list": List<dynamic>.from(staffList.map((x) => x.toJson())),
    };
}

class StaffList {
    String staffId;
    String name;
    String email;
    String phoneNo;
    String designation;
    String branchName;
    String imageUrl;
    bool editPermission;
    bool deletePermission;
    bool changePasswordPermission;
    String totalLeadsCount;
    String totalCallDuration;
    String totalCloudCallDuration;
    String totalClosedLeadCount;
    String totalClosedLeadCost;
    String targetAmount;
    String targetAmountAchieved;
    String targetPercentage;

    StaffList({
        required this.staffId,
        required this.name,
        required this.email,
        required this.phoneNo,
        required this.designation,
        required this.branchName,
        required this.imageUrl,
        required this.editPermission,
        required this.deletePermission,
        required this.changePasswordPermission,
        required this.totalLeadsCount,
        required this.totalCallDuration,
        required this.totalCloudCallDuration,
        required this.totalClosedLeadCount,
        required this.totalClosedLeadCost,
        required this.targetAmount,
        required this.targetAmountAchieved,
        required this.targetPercentage,
    });

    factory StaffList.fromJson(Map<String, dynamic> json) => StaffList(
        staffId: json["staffId"],
        name: json["name"],
        email: json["email"],
        phoneNo: json["phoneNo"],
        designation: json["designation"],
        branchName: json["branch_name"],
        imageUrl: json["imageUrl"],
        editPermission: json["edit_permission"],
        deletePermission: json["delete_permission"],
        changePasswordPermission: json["change_password_permission"],
        totalLeadsCount: json["total_leads_count"],
        totalCallDuration: json["total_call_duration"],
        totalCloudCallDuration: json["total_cloud_call_duration"],
        totalClosedLeadCount: json["total_closed_lead_count"],
        totalClosedLeadCost: json["total_closed_lead_cost"],
        targetAmount: json["target_amount"],
        targetAmountAchieved: json["target_amount_achieved"],
        targetPercentage: json["target_percentage"],
    );

    Map<String, dynamic> toJson() => {
        "staffId": staffId,
        "name": name,
        "email": email,
        "phoneNo": phoneNo,
        "designation": designation,
        "branch_name": branchName,
        "imageUrl": imageUrl,
        "edit_permission": editPermission,
        "delete_permission": deletePermission,
        "change_password_permission": changePasswordPermission,
        "total_leads_count": totalLeadsCount,
        "total_call_duration": totalCallDuration,
        "total_cloud_call_duration": totalCloudCallDuration,
        "total_closed_lead_count": totalClosedLeadCount,
        "total_closed_lead_cost": totalClosedLeadCost,
        "target_amount": targetAmount,
        "target_amount_achieved": targetAmountAchieved,
        "target_percentage": targetPercentage,
    };
}
